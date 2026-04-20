# Authenticated download strategy for GitHub release assets in private repos.
#
# Resolves a GitHub token in this order so team members don't have to manage
# raw PATs manually:
#
#   1. HOMEBREW_GITHUB_API_TOKEN (env var) — useful in CI or for power users
#   2. `gh auth token` output    — the common case; requires `gh auth login`
#
# goreleaser generates the formula automatically; this file only needs to
# exist in the tap so the generated `custom_require` line resolves.

require "download_strategy"
require "json"
require "open3"

class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  GH_CANDIDATES = [
    "gh",
    "/opt/homebrew/bin/gh",
    "/usr/local/bin/gh",
    "/home/linuxbrew/.linuxbrew/bin/gh",
  ].freeze

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    url_pattern = %r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid URL pattern for GitHub Release."
    end

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    "https://#{@github_token}@api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url,
                  "--header", "Accept: application/octet-stream",
                  to: temporary_path,
                  timeout: timeout
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release_metadata = fetch_release_metadata
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    raise CurlDownloadStrategyError, "Asset file not found." if assets.empty?

    assets.first["id"]
  end

  def fetch_release_metadata
    release_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}"
    result = curl_output "--header", "Authorization: token #{@github_token}", release_url
    unless result.status.success?
      raise CurlDownloadStrategyError, "Failed to fetch release metadata for #{@owner}/#{@repo} #{@tag}."
    end

    JSON.parse(result.stdout)
  end

  def set_github_token
    @github_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil) || gh_cli_token
    return if @github_token && !@github_token.empty?

    raise CurlDownloadStrategyError, <<~MSG
      Could not obtain a GitHub token for private release download.

      Install the GitHub CLI and authenticate once:
        brew install gh
        gh auth login

      Or export HOMEBREW_GITHUB_API_TOKEN with a PAT that has `repo` scope.
    MSG
  end

  def gh_cli_token
    GH_CANDIDATES.each do |gh|
      stdout, status = Open3.capture2(gh, "auth", "token")
      return stdout.strip if status.success? && !stdout.strip.empty?
    rescue Errno::ENOENT
      next
    end
    nil
  end
end
