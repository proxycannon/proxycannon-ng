# proxycannon-ng 

>Thank you **Wild West Hackin' Fest** for your help and support in our community-driven hackathon!  We've created a on-demand proxy tool that leverages cloud environments giving a user the ability to source (all) your traffic from an endless supply of  cloud based IP address. Think of it as your own private TOR network for your redteam and pentest engagements. No more defenses throttling and blocking you!

### Initial Release
Code and infrastructure has been developed, tested and proven viable. We're in the process of ironing out final changes and will have commits showing up this weekend (October 27/28).

  **Successes: **
  
   - VPN Server Build (scripted)
   - Client VPN (Full Tunnel)
   - Terraform Node Management (Build, Destroy, Routing)
   - AWS Multipath Node Routing (Load Balanced Exit Nodes)
   
### Getting Started

AWS Management
- Amazon AWS Account (Goal is to support multiple cloud providers, initial release is on AWS)
- Launch (1) Ubuntu Server t1-micro instance, recommend public AMI ami-0f65671a86f061fcd 

Build OpenVPN Server 
- cd into setup
- Run setup-load-balancing.sh (From this GIT repo)

Build Exit Nodes
- perform terraform prerequisites
- cd in nodes/aws then run:
```
terraform init
terraform apply
```

### Project History

Hackathon sponsored by [Sprocket Security](https://www.sprocketsecurity.com) and hosted at [Wild West Hackin' Fest 2018](https://www.wildwesthackinfest.com)   

<img align="left" width="55%" height="55%" src="https://github.com/proxycannon/proxycannon-ng/blob/master/docs/images/sprocket.png">  <img align="left" width="40%" height="40%" src="https://github.com/proxycannon/proxycannon-ng/blob/master/docs/images/wwhf.png">  

<br>
<br>
<br>
<br>
<br>
<br>
.

### Get Involved
Follow [@sprocketsec](https://www.twitter.com/sprocketsec) on twitter for live updates during the hackathon. 

Join us in [Slack](https://join.slack.com/t/hackfest-hq/shared_invite/enQtNDY1NjA4ODExNzYzLWNjM2EwMDIxN2RmYTgyMjNlMjhjMTgyYzQ0NzZkZGM1OGViOGFmYmMxNzMwZTAzMTlhMTkxODljODc5YTcxZTE) to discuss, contribute and troubleshoot. We'd love to hear from you.

### Implementation Diagram
![proxycannon-ng visual](https://github.com/proxycannon/proxycannon-ng/blob/master/docs/images/proxycannon-ng-visual.png)  

### Special Thanks
Special thanks to @i128 (@jarsnah12 on twitter) for developing the original proxycannon tool that is our inspirartion.

### Developers:  
Help a little or a lot and get your name listed here as a developer of an open-source security tool...looks good on a resume and sounds good at the bar ;-)

[@jarsnah12](https://www.twitter.com/jarsnah12) - original proxycannon v1 author  
[@w9hax](https://www.twitter.com/w9hax) - mad openVPN skillz  
[@caseycammilleri](https://www.twitter.com/caseycammilleri) - Gets lost deep in iptables  
**your name here**



