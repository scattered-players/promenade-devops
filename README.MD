# Promenade DevOps

## What in Bacchus' obscene name is this?

If you want to run a piece of online interactive immersive theatre, you've come to the right place.

We've got all the fixins:

- A backend server for managing actors, attendees and shows
- A FOSS media server that supports live videoconferencing (from the amazing Neapolitans at [meetEcho](https://janus.conf.meetecho.com/))
- A front-end app that tolerates your OffscreenCanvas freakiness

It's called *Promenade*. And we (a collective of actors, developers and actor/developers) have used it to make money. So now you have to listen to us. Sorry, I don't make the rules.

With this system you can have attendees buy tickets through EventBrite and attend your non-linear immersive online show. You don't have a non-linear immersive online show? Well now you have a platform for one, so come up with one, then come back here and read the rest of this README.

The next section will tell you how to get things set up. I'm not gonna lie to you, you should probably have a bit of programming or sysadmin knowledge if you want to run this thing. Or you better know someone who does. But if you do, this README will walk you through what you'll need in order to host a show.

And if it doesn't? If you follow these directions and can't get it running? Well then email chris.uehlinger@gmail.com and I will personally help you out. It's COVID time and we've all gotta look out for each other, so seriously, email me and I will do my best to help you.

## So You Want To Produce An Online Interactive Immersive Show?

I'd advise reading over **ALL** of these instructions **BEFORE** starting on any of them, just to be safe.

### Promenade Installation

1. **Get a suitable computer** All these scripts and such are built to run on either Linux, macOS or Windows Subsystem for Linux. Don't try and do this on Windows proper.
2. **Buy a domain and point the nameservers at Cloudflare** This will probably be under "Advanced DNS Settings" or something. Whenever I've used Cloudflare, the nameservers they give me are `liv.ns.cloudflare.com` and `scott.ns.cloudflare.com` although they do have others. After you do this, it can take **up to 48 hours** for the DNS system to start using the new nameservers (although sometimes it only takes an hour or two). So I'd advise you to **do this first**, then take care of the other things while that's happening.
2. **Set up AWS** Get an AWS account (you'll need a credit/debit card, but if you're new you'll be able to save money on the free tier for your first 12 months). Install the AWS CLI for your OS and log in with your credentials.
3. **Set up Cloudflare** Sign up for a free account. Create an API Token. When assigning permissions, make sure to add the "Zone" + "Edit" permission under the "Zone" category.
4. **Set up EventBrite** Create an EventBrite account and an event. This is where you'll be scheduling shows (Promenade will sync over any shows and tickets from EventBrite). Create **one multi-date event** for your show, not multiple events. Get an API Key, and copy down the Event Series ID for your event. 
5. **Install the other tools** You'll need git, mongodb, Node.js+npm, Terraform and Packer. You may also want Docker and Docker Compose if you're going to use custom containers, but if you're on WSL1 (which doesn't support Docker well) you can skip it.
6. **Fill out the tfvars file** By this point you should have all the keys and such that you'll need. Make a copy of the `terraform.template.tfvars` file, call it `terraform.tfvars` (it will be gitignored because you're about to enter sensitive information into it) and fill in the keys and values you got during the previous steps.
7. **Check if your nameservers are resolving yet** Run the command `dig @8.8.8.8 +short NS YOUR.DOMAIN` and make sure it's pointing at the new nameservers. Wait until it is before moving to step 8.
8. **Run the init script and fire away** Run `./init.sh`, which will automatically:
  - Set up Terraform
  - Set up your Cloudflare DNS routing
  - Create S3 buckets (one to host the front-end, one for config files, certs and secrets)
  - Fetch SSL certs via LetsEncrypt and store them in your secrets S3 bucket
  - Create an EBS volume that will house your Mongo DB data.
  - Build AMIs for the VMs that'll be running Mongo, the Show Service, the Janus WebRTC Media Servers and the load testing setup if you choose to use it later
  - Spin up EC2 Spot instances for Mongo DB, the Show Service and one Janus Media Server.
  - Cobble together a URL you can use to log into the Admin panel and start creating users.
9. Well uh, hold your horses. You can't log in until you've deployed the front end code, so go pull down the [Promenade starter]() and follow that ramshackle README until you've got it all deployed to your S3 bucket. Then try running `./get-admin-url.sh` and use the new login link.
10. **Shut it all down and don't waste money** After testing things out, use `sleep-mode.sh` to shut down all the VMs so you don't waste money.

### Running a show (or an evening of multiple shows)

1. Run `start-show.sh` to boot up Mongo, the Show Service, and the fleet of Janus servers.
2. Log into the Admin panel (https://YOUR.DOMAIN/admin). Your shows should appear on the "Today's Shows" tab.
3. Click the "SYNC FROM EVENTBRITE" button to sync over all the attendees. This is automatically done when the server boots up, but it's good to do it right before the show starts so you don't miss any late-coming ticket buyers.


### Running a show without needing scripts

If you want to hand off Promenade to someone who is less familiar with shell scripting (or if you want multiple people to be able to set up and tear down Promenade) you can sign up for a free account on Terraform cloud and add the `remote` backend to it as described [here](https://www.terraform.io/docs/backends/types/remote.html#basic-configuration). I'll add more specific setup instructions around Terraform Cloud if this angle really takes off.

## But I don't want to devise a new immersive show, I've really been dying to produce "American Buffalo" and--

Well %#$@$, go talk to [@brendanAbradley](https://twitter.com/brendanAbradley) about his [FutureStages](https://www.youtube.com/watch?v=1hy7cVGVMW8) project. His tools are all open source and he has a lot of good ideas around how to produce the existing canon of theatre for virtual audiences. It's going to take a variety of approaches to keep theatre going, and they're all totally valid.