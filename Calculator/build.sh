#!/bin/bash
# MiniCalc 构建脚本 - Android 1.0 (API 1) 极简计算器
# 纯代码UI + XML shape图标，SHA1 JAR签名兼容安卓1.0

set -e
export ANDROID_HOME=${ANDROID_HOME:-/home/user/android-sdk}
export PATH=$PATH:$ANDROID_HOME/build-tools/28.0.3
PLATFORM=$ANDROID_HOME/platforms/android-28/android.jar

echo "=== 1. 清理 ==="
rm -rf bin gen META-INF_tmp MiniCalc.apk
mkdir -p bin gen

echo "=== 2. 生成R.java + 编译Java ==="
aapt package -f -m -J gen -S res -I "$PLATFORM" -M AndroidManifest.xml
if command -v javac &>/dev/null; then
    javac -source 1.5 -target 1.5 -bootclasspath "$PLATFORM" -d bin src/com/minicalc/CalculatorActivity.java
else
    java -jar ecj.jar -source 1.5 -target 1.5 -cp "$PLATFORM" -d bin src/com/minicalc/CalculatorActivity.java
fi

echo "=== 3. 转 DEX ==="
dx --dex --output=bin/classes.dex bin

echo "=== 4. 打包资源+Manifest+DEX ==="
aapt package -f -S res -I "$PLATFORM" -M AndroidManifest.xml -F bin/unsigned.apk
cd bin && aapt add unsigned.apk classes.dex && cd ..

echo "=== 5. 对齐 ==="
zipalign -f 4 bin/unsigned.apk bin/aligned.apk

echo "=== 6. 生成密钥 (首次) ==="
if [ ! -f key.pem ]; then
    openssl req -x509 -newkey rsa:1024 -keyout key.pem -out cert.pem \
        -days 10000 -nodes -subj "/CN=MiniCalc" 2>/dev/null
fi

echo "=== 7. 手动JAR签名 (SHA1, 无signed attributes) ==="
mkdir -p META-INF_tmp
python3 - <<'PYEOF'
import hashlib, base64, zipfile
def b64(d): return base64.b64encode(d).decode()
def sha1(d): return hashlib.sha1(d).digest()
entries = []
with zipfile.ZipFile('bin/aligned.apk','r') as zf:
    for i in zf.infolist():
        if not i.filename.startswith('META-INF/'):
            entries.append((i.filename, zf.read(i.filename)))
lines = ['Manifest-Version: 1.0','Created-By: 1.0','']
for n,d in entries:
    lines.append(f'Name: {n}\r\nSHA1-Digest: {b64(sha1(d))}\r\n')
manifest = ('\r\n'.join(lines)+'\r\n').encode()
md = b64(sha1(manifest))
lines = ['Signature-Version: 1.0','Created-By: 1.0',f'SHA1-Digest-Manifest: {md}','']
mt = manifest.decode()
for n,_ in entries:
    idx = mt.find(f'Name: {n}\r\n')
    end = mt.find('\r\n\r\n', idx)
    if end<0: end=len(mt)
    block = mt[idx:end+2].encode()
    lines.append(f'Name: {n}\r\nSHA1-Digest: {b64(sha1(block))}\r\n')
sf = ('\r\n'.join(lines)+'\r\n').encode()
open('META-INF_tmp/MANIFEST.MF','wb').write(manifest)
open('META-INF_tmp/CERT.SF','wb').write(sf)
PYEOF

openssl smime -sign -in META-INF_tmp/CERT.SF -out META-INF_tmp/CERT.RSA \
    -signer cert.pem -inkey key.pem -outform DER -nodetach -md sha1 -noattr

python3 - <<'PYEOF'
import zipfile, os
entries = []
with zipfile.ZipFile('bin/aligned.apk','r') as zf:
    for i in zf.infolist():
        if not i.filename.startswith('META-INF/'):
            entries.append((i.filename, zf.read(i.filename)))
manifest = open('META-INF_tmp/MANIFEST.MF','rb').read()
sf = open('META-INF_tmp/CERT.SF','rb').read()
rsa = open('META-INF_tmp/CERT.RSA','rb').read()
with zipfile.ZipFile('MiniCalc.apk','w',zipfile.ZIP_DEFLATED) as zf:
    zf.writestr('META-INF/MANIFEST.MF', manifest)
    zf.writestr('META-INF/CERT.SF', sf)
    zf.writestr('META-INF/CERT.RSA', rsa)
    for n,d in entries:
        zf.writestr(n,d)
print(f"APK: {os.path.getsize('MiniCalc.apk')} bytes = {os.path.getsize('MiniCalc.apk')/1024:.2f} KB")
PYEOF

echo "=== 8. 验证签名 ==="
apksigner verify --verbose MiniCalc.apk 2>&1 | head -5

echo ""
echo "=== 构建完成: MiniCalc.apk ==="
ls -lh MiniCalc.apk
