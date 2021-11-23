def get_versions
  Spaceship::Tunes.login
  Spaceship::Tunes.select_team
  @app = Spaceship::Tunes::Application.find(@secret.app_id)
  live_version = @app.live_version
  edit_version = @app.edit_version

  @store_version = nil
  @store_build = nil

  @last_build = latest_testflight_build_number
  @last_version = lane_context[SharedValues::LATEST_TESTFLIGHT_VERSION]

  if live_version == nil
    @store_version = @last_version
    @store_build = @last_build
  else
    @store_version = live_version.version  
    @store_build = live_version.build_version
  end
  
  if edit_version == nil 
    @edit_version = @last_version
    @edit_build = @last_build
  else
    @edit_version = edit_version&.version
    @edit_build = edit_version&.build_version
  end

  UI.success("-------------------- App Version -----------------------")
  UI.success("Store: #{@store_version}/#{@store_build}")
  UI.success("Edit: #{@edit_version}/#{@edit_build}")
  UI.success("Last: #{@last_version}/#{@last_build}")
  UI.success("--------------------------------------------------------")
end

def versionize(bump: nil)
  set_version(bump: bump)
  set_build
  @version_string = "#{@version}/#{@build}"
end

def set_version(bump: nil)
  if @secret.require_version.nil?
    bump = nil
    version_to_bump = @secret.require_version
    UI.important("Using the passed version, ignoring bump")
  else
    version_to_bump = @store_version
    if bump == "minor" && should_use_edit_version
      version_to_bump = @edit_version
      UI.important(
        "bumping the version that is being sent the AppStore instead of the one that is live already"
      )
    end
  end
  @version = increment_version_number(xcodeproj: @secret.project.main, version_number: version_to_bump) # bump it if required
  @version = increment_version_number(xcodeproj: @secret.project.main, bump_type: bump) unless bump.nil?
  @version.to_s
end

def set_build
  latest_build = appcenter_last_build_number_for_version || 0
  @build = increment_build_number(xcodeproj: @secret.project.main, build_number: latest_build)
  @build = increment_build_number(xcodeproj: @secret.project.main)
end

def should_use_edit_version
  edit_version = @app.edit_version
  !edit_version.nil? && edit_version.raw_status != "prepareForUpload" &&
    edit_version.raw_status != "devRejected"
end # are we really preparing the version or the version is waiting for review?

def appcenter_last_build_number_for_version
  releases =
    appcenter_releases(
      api_token: @secret.app_center.token,
      owner_name: @secret.app_center.owner,
      app_name: @secret.app_center.app_name,
    )

  sorted_releases =
    releases.select { |x| x["short_version"] == @version }.sort_by do |x|
      x["id"]
    end

  latest_release = sorted_releases.last

  if latest_release.nil?
    UI.error("This app has no releases yet")
    return nil
  end

  latest_release["version"]
end

def testflight_last_build_number_for_version
  train = @app.build_trains[@version]
  testFlightBuild = train&.last&.build_version || 0
end
