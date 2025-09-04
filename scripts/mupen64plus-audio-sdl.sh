#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the rk3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

	  # Now we'll start the clone and build of mupen64plus-audio-sdl
	  if [ ! -d "mupen64plus-audio-sdl/" ]; then
		git clone --depth=1 https://github.com/mupen64plus/mupen64plus-audio-sdl.git
		#git clone --depth=1 https://github.com/OtherCrashOverride/mupen64plus-audio-sdl-go2.git -b libgo2 mupen64plus-audio-sdl
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the mupen64plus-audio-sdl standalone git.  Is Internet active or did the git location change?  Stopping here."
		  return 1
		fi
		cp patches/mupen64plus-audio-sdl-patch* mupen64plus-audio-sdl/.
	  else
		echo " "
		echo "A mupen64plus-audio-sdl subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the mupen64plus-audio-sdl folder and rerun this script."
		echo " "
		return 1
	  fi

	 cd mupen64plus-audio-sdl
	 
	 mupen64plus_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$mupen64plus_core_patches" ]]; then
	  for patching in mupen64plus-audio-sdl-patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			return 1
		   fi
		   rm "$patching" 
	  done
	 fi

      if [[ "$bitness" == "32" ]]; then
        _opts='USE_GLES=1 NEON=1 VFP_HARD=1 OPTFLAGS="-O3" V=1 PIE=1'
      else
        _opts='USE_GLES=1 NEW_DYNAREC=1 OPTFLAGS="-O3" V=1 PIE=1'
      fi
      
      export CFLAGS="-mtune=cortex-a55 -flto=$(nproc) -fuse-linker-plugin"
      export CXXFLAGS="$CXXFLAGS $CFLAGS"
      export LDFLAGS="$CFLAGS"
      
      make -C "projects/unix" clean
	  make -j$(nproc) -C "projects/unix" $_opts all

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest mupen64plus-audio-sdl standalone.  Stopping here."
		return 1
	  fi

	  strip projects/unix/mupen64plus-audio-sdl.so

	  if [ ! -d "../mupen64plussa-$bitness/" ]; then
		mkdir -v ../mupen64plussa-$bitness
	  fi

	  cp projects/unix/mupen64plus-audio-sdl.so ../mupen64plussa-$bitness/.
	  
	  echo " "
	  echo "mupen64plus-audio-sdl executable has been placed in workspace/mupen64plussa-$bitness subfolder"

