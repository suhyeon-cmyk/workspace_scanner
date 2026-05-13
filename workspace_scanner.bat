@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

title 최근 수정 파일 검색기

echo =====================================
echo 최근 수정 파일 검색기
echo =====================================
echo.

:: 디렉토리 입력
set /p SEARCH_DIR=검색할 디렉토리 입력 : 

if not exist "%SEARCH_DIR%" (
    echo.
    echo [오류] 디렉토리가 존재하지 않습니다.
    goto END
)

echo.

:: 날짜 입력
set /p DAYS=며칠 이내 수정 파일 검색? : 

set /a TEST_NUM=%DAYS% 2>nul

if errorlevel 1 (
    echo.
    echo [오류] 숫자만 입력해주세요.
    goto END
)

echo.

:: 확장자 입력
echo 예시: java,xml,jrxml,jsp
set /p EXT_LIST=확장자 입력 : 

if "%EXT_LIST%"=="" (
    echo.
    echo [오류] 확장자를 입력해주세요.
    goto END
)

:: 출력파일명 생성
for /f %%a in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do (
    set NOW=%%a
)

set OUTPUT=modified_files_%NOW%.txt

echo.
echo 검색중...
echo.

:: 기존 파일 삭제
if exist "%OUTPUT%" del "%OUTPUT%"

:: 헤더 작성
(
echo =====================================
echo 검색 디렉토리 : %SEARCH_DIR%
echo 최근 %DAYS%일 이내 수정 파일
echo 확장자 : %EXT_LIST%
echo target 폴더 제외
echo =====================================
echo.
) >> "%OUTPUT%"

:: 콤마 -> 공백
set EXT_LIST=%EXT_LIST:,= %

for %%e in (%EXT_LIST%) do (

    echo [검색중] %%e

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Get-ChildItem -Path '%SEARCH_DIR%' -Recurse -File -Filter '*.%%e' | " ^
    "Where-Object { $_.FullName -notmatch '\\target\\' -and $_.LastWriteTime -ge (Get-Date).AddDays(-%DAYS%) } | " ^
    "Sort-Object LastWriteTime -Descending | " ^
    "ForEach-Object { '{0}    [{1}]    {2}' -f $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'), '%%e', $_.FullName }" ^
    >> "%OUTPUT%"
)

echo.
echo 완료!
echo 결과 파일:
echo %OUTPUT%

:END
echo.
pause
