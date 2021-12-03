def get_versions
  #Spaceship::ConnectAPI.login
  token = Spaceship::ConnectAPI::Token.create(
    key_id: '767N26MG3W',
    issuer_id: '578c9b43-0b13-486a-9077-52e8a2c6434d',
    filepath:  File.absolute_path("../AuthKey_767N26MG3W.p8")
  )

  Spaceship::ConnectAPI.token = token
  Spaceship::ConnectAPI.select_team
  @app = Spaceship::ConnectAPI::App.find("com.peer.udel")
  live_version = @app.get_live_app_store_version
  edit_version = @app.get_edit_app_store_version()
  @store_version = live_version.version_string
  @store_build = live_version.build.version
  @edit_version = edit_version&.version_string
  @edit_build = edit_version&.build&.version
  @last_build = latest_testflight_build_number
  @last_version = lane_context[SharedValues::LATEST_TESTFLIGHT_VERSION]
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
  
  version_to_bump = "1.0"

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
  false
  # edit_version = @app.get_edit_app_store_version()
  # !edit_version.nil? && edit_version.app_store_state != "prepareForUpload" &&
  #   edit_version.app_store_state != "DEVELOPER_REJECTED"
end # are we really preparing the version or the version is waiting for review?

def appcenter_last_build_number_for_version
  releases =
    appcenter_releases(
      api_token: @secret.app_center.token,
      owner_name: @secret.app_center.owner,
      app_name: @secret.app_center.app_name,
    )

  sorted_releases =
    releases.select { |x| x["short_version"] == @version.strip }.sort_by do |x|
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

# deploy
