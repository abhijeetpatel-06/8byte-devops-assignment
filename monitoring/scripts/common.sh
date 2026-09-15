#!/usr/bin/env bash
# common.sh
# ------------------------------------------------------------------
# Chhota sa helper file jo baaki saare install_*.sh scripts source
# karte hain. Isme bas do cheeze hain:
#   1. log() - thoda color ke saath output, taki terminal me pata
#      chale ki kaunsa step chal raha hai
#   2. render_template() - config.env ki har variable ko __VAR__
#      pattern se dhoondh ke actual value se replace kar deta hai
#
# Isse alag rakha isliye taki har script me copy-paste na karna pade.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # reset

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1" >&2; }

# render_template <source_file> <destination_file>
# config.env me jo bhi variable defined hai, usko __VARNAME__ format
# me dhoond ke replace kar deta hai. Naya variable add karna ho to
# bas config.env me daal do, ye function apne aap pick kar lega.
render_template() {
    local src="$1"
    local dest="$2"
    local tmp
    tmp=$(mktemp)
    cp "$src" "$tmp"

    # config.env se saare "KEY=value" nikal ke ek ek karke sed se replace
    while IFS='=' read -r key value; do
        # comments aur khaali lines skip
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        # value ke around jo quotes hain unhe hata do
        value="${value%\"}"
        value="${value#\"}"
        # sed delimiter '|' use kiya kyuki URLs me '/' aata hai (webhook, smtp etc.)
        sed -i "s|__${key}__|${value}|g" "$tmp"
    done < <(grep -E '^[A-Z_]+=' "$SCRIPT_DIR/../config.env")

    mkdir -p "$(dirname "$dest")"
    mv "$tmp" "$dest"
    log "Rendered $(basename "$src") -> $dest"
}

# check_root - kai commands (useradd, systemctl, /etc me likhna) root maangte hain
check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "Ye script root/sudo se chalao yaar, warna aage ke steps fail ho jayenge."
        exit 1
    fi
}
