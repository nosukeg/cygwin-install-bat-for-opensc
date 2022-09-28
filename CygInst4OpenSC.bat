@echo off
cd /d %~dp0
setlocal enabledelayedexpansion

set CurrentDir=%~dp0
set CygRoot=%CurrentDir%Root
set CygPackage=%CurrentDir%Packages
set CygSite=https://your.favorite.site/pub/cygwin/
set InstallPackage="autoconf,autoconf2.5,automake,automake1.15,gcc-core,gcc-g++,git,libtool,make,pkg-config,libreadline-devel,zlib-devel,libssl-devel,openssl-devel,procps-ng,vim"

if exist %CygRoot% (
  echo Already %CygRoot% directory exists.
) else (
  mkdir %CygRoot%
)

if exist %CygPackage% (
  echo Already %CygPackage% directory exists.
) else (
  mkdir %CygPackage%
)

echo .\setup-x86_64.exe -q -W --root=%CygRoot% --local-package-dir=%CygPackage% --site=%CygSite% --packages=%InstallPackage% --no-shortcuts
.\setup-x86_64.exe -q -W --root=%CygRoot% --local-package-dir=%CygPackage% --site=%CygSite% --packages=%InstallPackage% --no-shortcuts

echo.
echo *** インストールが終わりました ***
echo.
echo ・このバッチファイル実行後、既存 Cygwin インストールを GUI でアップデート等する際に、Root Install および Local Package ディレクトリが変わっています。GUI 操作の過程で元に戻すことに注意します。
echo.
echo ・OpenSC を新規 Cygwin インストール上で make する為に、%CygRoot%\bin\mintty.exe のショートカットを適当な所（デスクトップ等）へ作り、そのプロパティ の リンク先 に オプション " -i /Cygwin-Terminal.ico -" を追加・適用し起動します。
echo.
echo ・mintty 起動後、画面の右クリック Options で ロケール と キャラクターセット や その他の項目 を、お好みに調整します。
echo.

pause
