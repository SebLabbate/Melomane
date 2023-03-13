require "bundler"
Bundler.require
@accounts = Spotify::Accounts.new
@accounts.client_id = "13a5a78c35794c128471c373008efb01"
@accounts.client_secret = "1cfa0c2e5bc04728b9e9e56731e0db20"
@accounts.redirect_uri = "http://localhost:3000/user_gigs/1"
@accounts.authorize_url
@session = @accounts.exchange_for_session(params[:code])
if @session.expired?
  @session.refresh!
end
@token = @session.refresh_token
@session = Spotify::Session.from_refresh_token(@accounts, @token)
@session.refresh!
@sdk = Spotify::SDK.new(@session)
@sdk.connect.devices
@sdk.connect.devices[0].play!({
  uri: "spotify:track:0tgVpDi06FyKpA1z0VMD4v",
  position_ms: 0
})
