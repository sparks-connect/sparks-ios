def prepare_changelog
  sh('git fetch')
  head = @secret.head_branch
  base = @secret.base_branch
  @changelog = sh("git log --oneline --no-merges --pretty=%s #{base}...#{head}")
  @changelog =
    @changelog.split(/\n+/).uniq.delete_if do |x|
      x.include?('IGNORE') || x.include?('pull request') || x.include?('bump')
    end
  @changes_count = @changelog.count
  @changelog
rescue => exception
  @changelog = ["Couldn't load changelog"]
end

def tag
  @tag = "#{@secret.env.purpose}/#{@version_string}"
  sh("git tag #{@tag}")
  sh('git push --tags')
rescue => exception
  @tag = "#{@secret.env.purpose}/#{@version_string}"
  UI.error(
    "Couldn't create a new tag, there might be a previous tag with the same signature"
  )
end

def create_release
  set_github_release(
    repository_name: @secret.repository_name,
    api_token: @secret.github_token,
    name: @version_string,
    tag_name: @tag,
    description: official_changelog
  )
  @release_link = lane_context[SharedValues::SET_GITHUB_RELEASE_HTML_LINK]
rescue StandardError
  @release_link = "Couldn't create release"
end

def official_changelog
  @changelog.select do |x|
    x.downcase.include?('atlassian') || x.downcase.include?('jira') ||
      x.downcase.include?('cai-') || x.downcase.include?('qa') ||
      x.downcase.include?('sentry') || x.downcase.include?('crash')
  end.join("\n")
end
