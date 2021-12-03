class Secret
  def env
    @env
  end

  def env=(env)
    @env = env
  end

  def appleId=(id)
    ENV["FASTLANE_USER"] = id
  end

  def appleIdPassword=(password)
    ENV["FASTLANE_PASSWORD"] = password
  end

  def appSpecificPassword=(password)
    ENV["FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD"] = password
  end

  def appSession=(session)
    ENV["FASTLANE_SESSION"] = session
  end

  def slack
    OpenStruct.new(   
      url: "https://hooks.slack.com/services/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",
      channel: "#sparks-release"
    )
  end

  def app_center
    OpenStruct.new(
      token: "904bb25ce41b22b3429b24c123bb92b6b83b49d8",
      owner: "Appwork",
      app_name: "Sparks",
    )
  end

  def firebase
    OpenStruct.new(
      token: "4/1AX4XfWgU7KoKZeHLnDU86pDYRRWYftUs95H0F3OHK-4Ta_0MneDsuiYyevI",
      app_id: "1:640617421139:ios:83905a9c729824356129a6",
    )
  end

  def diawi_token
    ""
  end

  def is_alpha
    @env == Secret.alpha
  end

  def github_token
    ENV["GITHUB_TOKEN"]
  end

  def repository_name
    "sparks-connect/sparks-ios"
  end

  def head_branch
    @github.head
  end

  def base_branch
    @github.base
  end

  def release_regex
    %r{^(release[\/](([0-9]+)\.([0-9]+)\.([0-9]+))?)$}
  end

  def require_version
    if @passed_version.nil?
      labels = @github.labels
      version = labels&.select { |x| x[:name]&.match(release_regex) }&.first
      return version[:name].split("/")[1] if (version&.length || 0) > 0
      return head_branch.split("/")[1] if head_branch&.match(release_regex)
      return nil
    else
      return @passed_version
    end
  end

  def app_id
    "1528064145"
  end

  def app_target
    "Sparks"
  end

  def project
    OpenStruct.new(
      main: "Sparks.xcodeproj",
      workspace: "Sparks.xcworkspace",
    )
  end

  def set_general_environment_variables(lane, branch)
    ENV["FASTLANE_SKIP_UPDATE_CHECK"] = "true"
    ENV["FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT"] = "120"
    ENV["FASTLANE_XCODEBUILD_SETTINGS_RETRIES"] = "5"
    @@lane = lane
    begin
      payload = JSON.parse(ENV["GIHUB_PAYLOAD"])
      @github =
        OpenStruct.new(
          head: "origin/#{payload["head_ref"]}",
          base: "origin/#{payload["base_ref"]}",
          labels: payload["event"]["pull_request"]["labels"],
        )
    rescue => exception
      UI.error(
        "There is no github payload in the environment, continue with local flow"
      )
      shouldUseMaster = lane == :release || lane == :pre_release
      @github =
        OpenStruct.new(
          head: branch,
          base: shouldUseMaster == true ? "origin/master" : "origin/development",
          labels: [],
        )
    end
    begin
      ENV["FASTLANE_ITC_TEAM_ID"] =
        CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id)
    rescue => exception
      UI.error(
        "Couldn't get the team id for AppStoreConnect from the appfile, if runing in terminal this won't be a problem"
      )
    end
  end

  def self.google
    OpenStruct.new(
      plistQA: "./Sparks/Supporting Files/GoogleService-Info.plist",
      plistRelease: "./Sparks/Supporting Files/GoogleService-Info.plist",
    )
  end

  def self.alpha
    OpenStruct.new(
      project: "Sparks.xcodeproj",
      scheme: "Sparks",
      configuration: "Adhoc",
      export_method: "ad-hoc",
      distribution_channel: "Firebase",
      release_environment: "Staging",
      purpose: "Alpha",
      googlePlist: self.google.plistQA,
      profile: "match AdHoc com.appwork.sparks"
    )
  end

  def self.beta
    OpenStruct.new(
      project: "Sparks.xcodeproj",
      scheme: "Sparks",
      configuration: "Release",
      export_method: "app-store",
      distribution_channel: "TestFlight",
      release_environment: "Production",
      purpose: "Beta",
      googlePlist: self.google.plistRelease,
      profile: "match AppStore com.appwork.sparks"
    )
  end
end
