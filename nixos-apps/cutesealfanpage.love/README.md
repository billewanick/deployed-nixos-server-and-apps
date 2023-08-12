# Cute Seal Fanpage

> An experiment using [Nix](https://nixos.org/), [Hakyll](https://jaspervdj.be/hakyll/), [Haskell](https://www.haskell.org/), and [shell scripts](https://en.wikipedia.org/wiki/Bourne_shell) to automate a simple website deployment pipeline.

## Why Seals?

It's an in-joke.

## What's all this code?

seal-blog/

- devops/
  - build.sh
    - Uses a [nix-shell](https://nixos.wiki/wiki/Development_environment_with_nix-shell) expression to build the Hakyll executable

  - configuration.nix
    - The [configuration file for the NixOS](https://nixos.org/manual/nixos/stable/index.html#ch-configuration) production server. This takes care of installing all the necessary software, setup [Nginx](https://www.nginx.com/), and get [ACME certs](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment) for verification.

  - newSealPost.sh
    - Script to be called daily by a cron job on the server. Generates the post for the day, builds and commits.

- website/
  - A basic Hakyll site, slightly modified to serve seals. Most of the site is generated from the `site.hs` file. Check the [Hakyll](https://jaspervdj.be/hakyll/) documentation for more info.

## Work to be done

- The blog post generation and the hosting of the website are currently intertwined when they should be separated
  - Seal post generator just makes posts
  - Hakyll blog imports or calls the post generator
  - The deployed server/nix config file has a cron job for adding a new blog and committing every day
- Need to move the blog and post generation inside nixos-apps on my beefier server
  - The configuration file here is for it's own Linode, the current small one running, but I have a better setup for that now
  - Pull out the useful parts for my deployed server, remove anything not necessary for a small config file
  - Also switch to using caddy if not already
- Experiment with `*` A records
  - For the seal blog
  - Instead of having `www` and `git` and `...` subdomains spelled out in Namecheap
  - Just have a `*` record and have caddy do the filtering
