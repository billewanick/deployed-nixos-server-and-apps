{ pkgs, ... }:

let
  PROJECT_ROOT = builtins.toString ./.;
in
{
  services.caddy = {
    enable = true;
    virtualHosts = {
      "cutesealfanpage.love" = {
        serverAliases = [ "www.cutesealfanpage.love" ];
        extraConfig = ''
          root * ${PROJECT_ROOT}/cutesealfanpage.love/_site
          file_server
        '';
      };
    };
  };

  systemd.services = {
    cutesealfanpage-hakyll-site = {
      enable = true;
      description = "The hakyll executable that rebuilds the site when a new blog post is created.";
      serviceConfig = {
        ExecStart = "cd ${PROJECT_ROOT}/cutesealfanpage.love; ${pkgs.nix}/bin/nix run .#hakyll-site -- watch --no-server";
      };
    };

    cutesealfanpage-generatePosts = {
      enable = true;
      description = "The haskell script that creates the new post of the day.";
      startAt = "08:12:42";
      serviceConfig = {
        ExecStart = "echo Hello; cd ${PROJECT_ROOT}/cutesealfanpage.love; ${pkgs.nix}/bin/nix run .#generateSealPosts";
      };
    };
  };

  # when in doubt, clear away the certs with
  # sudo rm -rf /var/lib/acme/
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "admin@cutesealfanpage.love";
  # uncomment this to use the staging server
  # security.acme.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "12 12 * * *   alice   . /etc/profile; ${pkgs.newSealPost} > /home/alice/logs/backup.log 2>&1"
  #   ];
  # };
}
