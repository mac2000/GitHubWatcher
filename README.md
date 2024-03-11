# GitHubWatcher

<img width="200" alt="image" src="https://github.com/mac2000/GitHubWatcher/assets/88868/9dd894c6-e16f-4001-be22-755e0f59f960">

Problem: it is hard to keep track of pull requests awaiting for review and those ready to be merged

Idea: why not have an dedicated widget that will kindly remind about them

## How it works

The app itself does nothing useful and just used to store token that can be created [here](https://github.com/settings/tokens)

<img width="400" alt="image" src="https://github.com/mac2000/GitHubWatcher/assets/88868/70db1506-b211-40d5-9ca6-0aad858d297d">

After we save token, app will confirm if everything ok by printing an message with number of retrieved pull requests and we can add widget

Widget itself, every 15 minutes will talk to GitHub API to retrieve pull requests lists and itsefl.

Numbers on widget are clickable and pointing to corresponding GitHub pages.

## Tech details

Key components

- `KeychainManager` - simple wrapper around Keychain with basic save, delete methods
- `CredentialsManager` - another wrapper around `KeychainManager` - for our app we need only token, so we are hidding everything else
- `GitHubManager` - api client that has methods for retrieving data, and uses credentials manager

Widget links

Unfortunatelly there is not way to have links right inside widget, any link will open application instead

Thats why we are doing workaround with deep links, aka click on the number in widget - opens deep link, inside we are checking if everything ok, open Safari and immediatelly terminate app
