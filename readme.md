### Proxycannon Redux

This project is a fork of the work done by Sprocket Security in **proxycannon-ng**.
```https://github.com/proxycannon/proxycannon-ng```

The goal of this fork was two part:
A. Add functionality for Digital Ocean since that was our VPS of choice and
2. Simplify the user's interaction with the tool

##### Major changes from the original include:
  - Use Terraform to create the command server as well as the exit nodes
  - Create a user interactive script to build the entire infrastructure
  - Added support for Digital Ocean
  - Simplified the content needed to accomplish these goals

##### More to-dos:
  - Add Azure Support
  - Create VPN for Command Nodes and Exit Nodes
  - Work on some form of logging for tracking purposes

#### How-to
1. Add the following variables to `proxycannon.tfvars` before running
    - Private SSH Key File Location to `variable key-file`
    - Public Key Name (for VPS of Choice) to `variable sshName`
    - API Token (for VPS of Choice) to the appropriate variable
      - Only uncomment the provider of choice
2. Run `sudo ./proxycannon.sh -p <PROVIDER ID> -c <EXIT-NODE-COUNT>`
    - Run `sudo ./proxycannon.sh -h` for a list of the provider IDs needed for `-p`
3. Run `cd connection-pack/ && sudo openvpn --config proxycannon-config.conf`
    - You may need to change directory to `.../proxycannon/tfdocs/connection-pack/` depending on where you installed proxycannon
4. Run `sudo ./proxycannon.sh -p <PROVIDER ID> -d` to delete the exit nodes and command server from your VPS
