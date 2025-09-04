#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the rk3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################


cur_wd="$PWD"
bitness=64

   cd "$cur_wd"
   source scripts/mupen64plus-core.sh
   # mupen64plus-core.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-core build failed. Stopping all mupen64plussa builds."
       return 1 # mupen64plussa.sh 스크립트 실행 중단
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-rsp-hle.sh
   # mupen64plus-rsp-hle.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-rsp-hle build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-audio-sdl.sh
   # mupen64plus-audio-sdl.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-audio-sdl build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-input-sdl.sh
   # mupen64plus-input-sdl.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-input-sdl build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-ui-console.sh
   # mupen64plus-ui-console.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-ui-console build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-video-rice.sh
   # mupen64plus-video-rice.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-video-rice build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-video-glide64mk2.sh
   # mupen64plus-video-glide64mk2.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-video-glide64mk2 build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   source scripts/mupen64plus-video-gliden64.sh
   # mupen64plus-video-gliden64.sh 빌드 결과 확인
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: mupen64plus-video-gliden64 build failed. Stopping all mupen64plussa builds."
       return 1
   fi

   cd "$cur_wd"
   gitcommit=$(git --git-dir mupen64plus-core/.git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
   # git commit 추출 실패 여부 확인 (선택 사항)
   if [[ $? != "0" ]]; then
       echo " "
       echo "Error: Failed to get git commit info. Stopping all mupen64plussa builds."
       return 1
   fi

   if [ ! -d "mupen64plussa-$bitness/" ]; then
     mkdir -v "mupen64plussa-$bitness"
   fi


echo " "
echo "Viola! Fini! All Done! Check the mupen64plussa-$bitness for the individual modules as well as the mupen64plus-${gitcommit}.tar.gz package."