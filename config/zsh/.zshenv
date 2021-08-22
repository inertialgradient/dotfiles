# shellcheck source=/dev/null
source "${HOME}/.dotfiles/env/setup.sh"

# zsh config execution order
# ----------------------------
#                                Interactive login | Interactive non-login | Script |
# |---------------------------:|:-----------------:|:---------------------:|:------:|
# |                /etc/zshenv |         A         |           A           |    A   |
# |                  ~/.zshenv |         B         |           B           |    B   |
# |              /etc/zprofile |         C         |                       |        |
# |                ~/.zprofile |         D         |                       |        |
# |                 /etc/zshrc |         E         |           C           |        |
# |                   ~/.zshrc |         F         |           D           |        |
# |                /etc/zlogin |         G         |                       |        |
# |                  ~/.zlogin |         H         |                       |        |
# |   ~/.zlogout (logout only) |         I         |                       |        |
# | /etc/zlogout (logout only) |         J         |                       |        |

# disable to prevent /etc/profile from overwriting
# possible replacement: https://github.com/yb66/path_helper
if [ -x /usr/libexec/path_helper ]; then
  function noop () { }
  alias '/usr/libexec/path_helper'=noop
fi
