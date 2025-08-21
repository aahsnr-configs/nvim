{ pkgs, ... }: {
  #SSH Configuration for multiple GitHub accounts
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Configs GitHub account (Primary)
      "github.com-aahsnr-configs" = {
        hostname = "github.com";
        user = "git";
        # Uses a dedicated, modern Ed25519 key for this account.
        identityFile = "~/.ssh/id_ed25519_aahsnr_configs";
        extraOptions = {
          # Automatically adds the key to the SSH agent for secure, password-less use.
          AddKeysToAgent = "yes";
          IdentitiesOnly = "yes";
        };
      };

      # Personal GitHub account
      "github.com-aahsnr-personal" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_aahsnr_personal";
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentitiesOnly = "yes";
        };
      };

      # Work GitHub account
      "github.com-aahsnr-work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_aahsnr_work";
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentitiesOnly = "yes";
        };
      };

      # common GitHub account
      "github.com-aahsnr-common" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_aahsnr_common";
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentitiesOnly = "yes";
        };
      };
    };
  };

  # Git configuration with conditional includes for identity switching
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    # Default configuration (aahsnr-configs account)
    userName = "aahsnr-configs";
    userEmail = "ahsanur041@proton.me";

    extraConfig = {
      init.defaultBranch = "main";
      # Other global settings...
    };

    # Conditional includes switch user identity based on directory
    includes = [
      {
        condition = "gitdir:~/git-repos/personal/";
        contents = {
          user = {
            name = "aahsnr-personal";
            email = "ahsanur041@gmail.com";
          };
        };
      }
      {
        condition = "gitdir:~/git-repos/work/";
        contents = {
          user = {
            name = "aahsnr-work";
            email = "aahsnr041@proton.me";
          };
        };
      }
      {
        condition = "gitdir:~/git-repos/common/";
        contents = {
          user = {
            name = "aahsnr-common";
            email = "ahsan.05rahman@gmail.com";
          };
        };
      }
    ];
  };

  # GitHub CLI configuration
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };

  # Helper script for one-time SSH key generation
  home.file.".local/bin/setup-github-keys" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "Setting up SSH keys for multiple GitHub accounts..."
      mkdir -p ~/.ssh
      chmod 700 ~/.ssh

      generate_key() {
          local key_name="$1"
          local email="$2"
          local key_path="$HOME/.ssh/id_ed25519_$key_name"

          if [[ ! -f "$key_path" ]]; then
              echo "Generating modern Ed25519 SSH key for '$key_name'..."
              ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""
              # Set secure file permissions: 600 for private, 644 for public.
              chmod 600 "$key_path"
              chmod 644 "$key_path.pub"
              echo "-> Generated key: $key_path"
          else
              echo "-> Key for '$key_name' already exists: $key_path"
          fi
      }

      # IMPORTANT: Replace these emails with your actual GitHub account emails
      generate_key "aahsnr_configs" "ahsanur041@proton.me"
      generate_key "aahsnr_personal" "ahsanur041@gmail.com"
      generate_key "aahsnr_work" "aahsnr041@proton.me"
      generate_key "aahsnr_common" "ahsan.05rahman@gmail.com"

      echo ""
      echo "Setup complete! Next steps:"
      echo "1. Add the following public keys to your respective GitHub accounts:"
      echo "   - Configs:  cat ~/.ssh/id_ed25519_aahsnr_configs.pub"
      echo "   - Personal: cat ~/.ssh/id_ed25519_aahsnr_personal.pub"
      echo "   - Work:     cat ~/.ssh/id_ed25519_aahsnr_work.pub"
      echo "   - common:    cat ~/.ssh/id_ed25519_aahsnr_common.pub"
      echo ""
      echo "2. IMPORTANT: Enable Two-Factor Authentication (2FA) on all GitHub accounts."
      echo ""
      echo "3. Test your SSH connections:"
      echo "   ssh -T git@github.com-aahsnr-configs"
      echo "   ssh -T git@github.com-aahsnr-personal"
      echo "   ssh -T git@github.com-aahsnr-work"
      echo "   ssh -T git@github.com-aahsnr-common"
      echo ""
      echo "4. Create your project directories:"
      echo "   mkdir -p ~/git-repos/configs ~/git-repos/personal ~/git-repos/work ~/git-repos/common"
    '';
  };
}
