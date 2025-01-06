@echo off
:: To use me
:: curl -O https://raw.githubusercontent.com/alastorid/MeloTTS/refs/heads/main/Go.cmd & go
if exist ..\APPDATA (
	set APPDATA=%~dp0..\APPDATA
	set HF_HOME=%~dp0..\hf_home
	set TRANSFORMERS_CACHE=%~dp0..\hf_home
) else (
	if not exist APPDATA (mkdir APPDATA)
	if not exist hf_home (mkdir hf_home)
	set APPDATA=%~dp0APPDATA
	set HF_HOME=%~dp0hf_home
	set TRANSFORMERS_CACHE=%~dp0hf_home
)

rem :: get python ready
rem if not exist python ( mkdir python )
rem if not exist python\_CACHE ( mkdir python\_CACHE )
rem path %~dp0python;%~dp0python\Scripts;%Path%
rem set PIP_CACHE_DIR=%~dp0python\_CACHE

rem where python || (
rem 	pushd python &&(
rem 		curl -L -O -c - https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip
rem 		curl -L -O -c - https://bootstrap.pypa.io/get-pip.py
rem 		tar -xvf python-3.10.11-embed-amd64.zip
rem 		echo import site>>python310._pth
rem 		mkdir Lib\site-packages
rem 		(
rem 			echo import sys
rem 			echo import os
rem 			echo if os.getcwd^(^) not in sys.path:
rem 			echo     sys.path.insert^(0, os.getcwd^(^)^)
rem 		) > Lib\site-packages\sitecustomize.py
rem 		python get-pip.py
rem 		pip install setuptools wheel pip-system-certs certifi
rem 		popd
rem 	)
rem )
rem :: fixup
rem for /f "delims=" %%i in ('python -m certifi') do set "SSL_CERT_FILE=%%i"

:: get conda
if not exist ..\conda if not exist conda (
	mkdir conda
	rem Miniconda3-latest-Windows-x86_64.exe <- big trouble
	rem Miniconda3-py310_24.11.1-0-Windows-x86_64.exe
	curl -L -O -c - https://repo.anaconda.com/miniconda/Miniconda3-py310_24.11.1-0-Windows-x86_64.exe
	Miniconda3-py310_24.11.1-0-Windows-x86_64.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%~dp0conda
	move Miniconda3-py310_24.11.1-0-Windows-x86_64.exe conda\
)
if exist ..\conda (
    set "Path=%~dp0..\conda;%~dp0..\conda\Scripts;%Path%"
) else (
    set "Path=%~dp0conda;%~dp0conda\Scripts;%Path%"
)

:: get git ready
2>nul where git || (
	if not exist ..\git if not exist git (
		mkdir git
		pushd git && (
			curl -L -O -c - https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/PortableGit-2.47.1-64-bit.7z.exe
			echo Extract PortableGit-2.47.1-64-bit.7z.exe to %~dp0git\
			cmd /c PortableGit-2.47.1-64-bit.7z.exe -o. -y
			popd
		)
	)
)
if exist ..\git (
    set "Path=%~dp0..\git\bin;%Path%"
) else (
    set "Path=%~dp0git\bin;%Path%"
)

git clone --recursive https://github.com/bmaltais/kohya_ss.git

pip show melotts || (
	:: get MeloTTS ready
	if not exist MeloTTS (
		if "%date:~10,4%"=="2025" (
			git clone https://github.com/alastorid/MeloTTS.git
		) else (
			git clone https://github.com/myshell-ai/MeloTTS.git
		)
		pushd MeloTTS &&(
			pip install -e .
			where nvidia-smi && (
				rem pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
				pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
				rem pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
			)
			where nvidia-smi || (
				pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
			)
			python -m unidic download
			(
				echo import nltk
				echo nltk.download^('averaged_perceptron_tagger_eng'^)
			) > download_sth.py
			python download_sth.py
			del download_sth.py
			popd
		)
	)
)

melo-ui %*
