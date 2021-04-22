Bash based generation of mender compatible artifacts

Needed some bash commands for azure devops to deploy artifacts to mender without bringing in any extra tools.

Yes, these ones aren't signed. For mender 2.6, and artifact format v3. Self hosted mender

interesting things
- sha256sum stuffs the sha and the name into the manifest but mender expects 2 spaces, not 1, weird. (stufts?)
- order maters in the tar's, must match manifest
