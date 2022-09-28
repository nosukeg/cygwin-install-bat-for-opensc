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
echo *** �C���X�g�[�����I���܂��� ***
echo.
echo �E���̃o�b�`�t�@�C�����s��A���� Cygwin �C���X�g�[���� GUI �ŃA�b�v�f�[�g������ۂɁARoot Install ����� Local Package �f�B���N�g�����ς���Ă��܂��BGUI ����̉ߒ��Ō��ɖ߂����Ƃɒ��ӂ��܂��B
echo.
echo �EOpenSC ��V�K Cygwin �C���X�g�[����� make ����ׂɁA%CygRoot%\bin\mintty.exe �̃V���[�g�J�b�g��K���ȏ��i�f�X�N�g�b�v���j�֍��A���̃v���p�e�B �� �����N�� �� �I�v�V���� " -i /Cygwin-Terminal.ico -" ��ǉ��E�K�p���N�����܂��B
echo.
echo �Emintty �N����A��ʂ̉E�N���b�N Options �� ���P�[�� �� �L�����N�^�[�Z�b�g �� ���̑��̍��� ���A���D�݂ɒ������܂��B
echo.

pause
