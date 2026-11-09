#!/bin/bash
# OpenClaw 자동 설치 스크립트 (ver2.0, macOS Apple Silicon)
# Homebrew → Node 24 → OpenClaw(latest) 순서로 설치합니다.
set -e

echo ""
echo "=================================================="
echo " OpenClaw 자동 설치 스크립트 (ver2.0)"
echo "=================================================="
echo ""

# ── 1. Homebrew ──────────────────────────────────────
echo "▶ [1/4] Homebrew 확인 중..."
if [[ -x /opt/homebrew/bin/brew ]]; then
  BREW=/opt/homebrew/bin/brew
elif [[ -x /usr/local/bin/brew ]]; then
  BREW=/usr/local/bin/brew
else
  echo "  Homebrew 설치를 시작합니다. 맥 로그인 비밀번호를 물으면 입력하세요 (화면에 글자가 보이지 않는 것이 정상입니다)."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW=/opt/homebrew/bin/brew
fi
eval "$("$BREW" shellenv)"
if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
  echo "eval \"\$($BREW shellenv)\"" >> ~/.zprofile
fi
echo "✅ Homebrew 준비 완료 ($(brew --version | head -n 1))"

# ── 2. Node 24 ───────────────────────────────────────
echo ""
echo "▶ [2/4] Node 24 확인 중..."
if ! node -v 2>/dev/null | grep -q "^v24"; then
  brew install node@24
  brew link --overwrite --force node@24
fi
echo "✅ Node 준비 완료 (node $(node -v), npm $(npm -v))"

# OpenClaw 게이트웨이(백그라운드 서비스)가 버전 없는 경로로 node를 찾는 경우를 대비한 링크
BREW_PREFIX=$(brew --prefix)
if [[ -d "$BREW_PREFIX/opt/node@24" && ! -e "$BREW_PREFIX/opt/node" ]]; then
  ln -sfn "$BREW_PREFIX/opt/node@24" "$BREW_PREFIX/opt/node" 2>/dev/null || true
fi

# ── 3. OpenClaw 설치 ─────────────────────────────────
# OpenClaw는 내 홈 폴더(~/.npm-global)에 설치합니다.
# 이 맥에 Homebrew·Node·OpenClaw가 이미 다른 계정으로 설치돼 있어도 충돌하지 않고, sudo도 필요 없습니다.
echo ""
echo "▶ [3/4] OpenClaw 설치 중... (1~3분)"
NPM_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_PREFIX"
npm config set prefix "$NPM_PREFIX"
export PATH="$NPM_PREFIX/bin:$PATH"
if ! grep -q '.npm-global/bin' ~/.zprofile 2>/dev/null; then
  echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zprofile
fi
npm install -g --allow-scripts=@google/genai,esbuild,koffi,protobufjs,openclaw openclaw@latest
hash -r
echo "✅ OpenClaw 설치 완료 ($(openclaw --version))"

# ── 4. 마무리 ────────────────────────────────────────
echo ""
echo "▶ [4/4] 마무리 중..."
mkdir -p ~/.openclaw
echo "✅ 완료"

echo ""
echo "=================================================="
echo " 🎉 설치 완료!"
echo " 이 터미널을 닫고, 새 터미널 창에서 아래 명령어를 입력하세요:"
echo ""
echo "   openclaw onboard"
echo ""
echo "=================================================="
