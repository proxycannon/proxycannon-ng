# Proxycannon Redux

>This project is a reintroduction of the concepts created by the original proxycannon-ng. The original proxycannon was devised by Sprocket Security during the Wild West Hackin' Fest's hackathon.

This project was forked from the original [proxycannon-ng](https://github.com/proxycannon/proxycannon-ng) repo.

### Why change things?

Ultimately, we noticed that the original repo was not very active. The original targeted compatibility with other virtual providers and it hadn't come. We primarily used Digital Ocean and wanted to get that piece working. Enter our effort.

Then, we began to identify areas to simplify the application usage. For instance we moved the creation of the command server as a part of the terraform execution instead of requiring the user to have one created to begin.

Now things are a little more simplified and direct. The user (probably you) would just need add SSH and API token information to `proxycannon.tfvars` to enable authentication. Then all that needs to happen is running `proxycannon.sh` and indicate the provider with `-p` and the number of exit nodes with `-c`. The number of exit nodes is also theoretically endless so long as you can pay for it.

![Basic Proxycannon Network Map](https://github.com/blacklanternsecurity/proxycannon-ng/blob/master/imgs/ProxyCannon.png)

### Changelog
- Added Digital Ocean functionality
- Simplified the amount of data the user needs to provide to run the tool
- Included the proxycannon command server/load balancer in the Terraform creation
- Updated AWS function to accommodate the new command node creation

### Target Changes
- Add Azure functionality
- Add other provider functionality as we find the desire/need for them
- Create mix-provider networks
- Improve firewalls
- Add VPN support between Command and Nodes
- Some kind of logging

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
