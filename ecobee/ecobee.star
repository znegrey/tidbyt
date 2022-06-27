"""
Applet: Ecobee
Summary: Show Ecobee info on Tidbyt
Description: Display Ecobee temperature
Author: Zach Negrey
"""
load("render.star", "render")
load("schema.star", "schema")
load("secret.star", "secret")
load("http.star", "http")
load("cache.star", "cache")
load("encoding/json.star", "json")

# ecobee pin auth startup: https://www.ecobee.com/home/developer/api/examples/ex1.shtml

# todo: look into secret.decrypt
# ECOBEE_API_KEY = "" # oauth
ECOBEE_API_KEY = "" # pin
# REDIRECT_URI = "" # https://appauth.tidbyt.com/ecobee
# todo: caches won't work on multiple things right now.
TEMP_REFRESH_TOKEN=""

def main(config):
    debug_pin_handler()
    temperature = get_temperature()
    print("main: temperature", temperature)

    return render.Root(
        child = render.Text("ecobee: " + str(temperature)),
    )

def debug_pin_handler():
    # first time:
    # params = dict(
    #     grant_type = "ecobeePin",
    #     code = "",
    #     client_id = ECOBEE_API_KEY,
    # )
    # done = update_token_cache(params)
    # future times:
    cache.set("refresh_token", TEMP_REFRESH_TOKEN)

def get_temperature():
    access_token = get_access_token()

    temperature = -998
    if not access_token:
        temperature = -999
    else:
        temperature = cache.get("temperature") # todo: cache must be unique to token?
        if not temperature:
            print("getting updated temp")
            headers = {
                "Content-Type": "text/json",
                "Authorization": "Bearer %s" % access_token,
            }

            url = 'https://api.ecobee.com/1/thermostat?format=json&body={"selection":{"selectionType":"registered","selectionMatch":"","includeRuntime":true}}'
            res = http.get(
                url, 
                headers = headers,
                form_encoding = "application/x-www-form-urlencoded"
            )
            if res.status_code != 200:
                fail("get_temperature request failed with status code: %d - %s" % (res.status_code, res.body()))
            data = res.json()
            thermostatList = data["thermostatList"]
            runtime = thermostatList[0]["runtime"] # todo handle multiple ecobees
            actualTemperature = runtime["actualTemperature"]
            temperature = str(actualTemperature / 10)
            cache.set("temperature", temperature, ttl_seconds = 60)
        else:
            print("using cached temperature")

    return temperature

def get_access_token():
    access_token = cache.get("access_token")
    if not access_token:
        refresh_token = cache.get("refresh_token")
        if not refresh_token:
            fail("get_access_token fail, need to fully reauth")

        params = dict(
            grant_type = "refresh_token",
            refresh_token = refresh_token,
            client_id = ECOBEE_API_KEY,
            ecobee_type = "jwt",
        )
        update_token_cache(params)
        access_token = cache.get("access_token")
    
    # if still no access_token, must re-auth app.
    return access_token

# https://www.ecobee.com/home/developer/api/documentation/v1/auth/token-refresh.shtml
def update_token_cache(params):
    url = "https://api.ecobee.com/token"
    res = http.post(
        url = url,
        headers = {
            "Accept": "application/json",
        },
        params = params,
        form_encoding = "application/x-www-form-urlencoded",
    )
    if res.status_code != 200:
        fail("update_token_cache request failed with status code: %d - %s" % (res.status_code, res.body()))

    token_response = res.json()
    access_token = token_response["access_token"]
    refresh_token = token_response["refresh_token"]
    expires_in = int(token_response["expires_in"])

    cache.set("access_token", access_token, ttl_seconds = expires_in - 60)
    cache.set("refresh_token", refresh_token, ttl_seconds = expires_in - 60)

    # Tokens must be refreshed per https://www.ecobee.com/home/developer/api/documentation/v1/auth/token-refresh.shtml
    # Access Token lasts 3600 seconds (1 hour)
    # Refresh Token lasts 1 year (14 days if it is the first refresh token returned immediately after authorization)
    # Since we'll refresh the access_token every 59mins, we should be ok if we keep the refresh_token around.
    print("new access_token: ", access_token)
    print("new refresh_token: ", refresh_token)

# todo: look into oauth instead of pin auth?
# https://www.ecobee.com/home/developer/api/documentation/v1/auth/authz-code-authorization.shtml
# def oauth_handler(params):
#     params = json.decode(params)
#     authorization_code = params.get("code")
#     params = dict(
#         grant_type = "authorization_code",
#         code = authorization_code,
#         redirect_uri = str(REDIRECT_URI),
#         client_id = ECOBEE_API_KEY,
#         ecobee_type = "jwt",
#     )
#     # update_token_cache(params)
#     # get_temperature()

# OAuth2: https://github.com/tidbyt/pixlet/blob/main/docs/schema/schema.md#oauth2
# def get_schema():
#     return schema.Schema(
#         version = "1",
#         fields = [
#             schema.OAuth2(
#                 id = "auth",
#                 name = "Ecobee",
#                 desc = "Connect your Ecobee account.",
#                 icon = "cloud",
#                 handler = oauth_handler,
#                 client_id = str(ECOBEE_API_KEY) + "&response_type=code" + "&redirect_uri=" + str(REDIRECT_URI), # temp for local
#                 authorization_endpoint = "https://api.ecobee.com/authorize",
#                 scopes = [
#                     "smartRead",
#                 ],
#             ),
#         ],
#     )
