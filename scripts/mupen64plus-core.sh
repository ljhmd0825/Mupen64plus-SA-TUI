#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the rk3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

	  # Now we'll start the clone and build of mupen64plus-core
	  if [ ! -d "mupen64plus-core/" ]; then
		#git clone --depth=1 https://github.com/OtherCrashOverride/mupen64plus-core-go2 mupen64plus-core
		git clone --depth=1 https://github.com/mupen64plus/mupen64plus-core.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the mupen64plus-core standalone git.  Is Internet active or did the git location change?  Stopping here."
		  return 1
		fi

        echo "Applying Makefile patch to exclude x64 dynarec from AArch64 build..."
        sed -i '/^\s*$(CORE_DIR)\/device\/r4300\/new_dynarec\/x64/d' mupen64plus-core/projects/unix/Makefile
        if [[ $? != "0" ]]; then
            echo " "
            echo "Error: Failed to patch mupen64plus-core Makefile."
            # return 1 # (이전에 exit 1 -> return 1 변경하셨다면 이렇게 되어 있을 것입니다.)
            return 1 # (원래대로 exit 1이면 컨테이너 종료되니 확인 필요)
        fi
        echo "Makefile patched successfully."

		cp patches/mupen64plus-core-patch* mupen64plus-core/.
	  else
		echo " "
		echo "A mupen64plus-core subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the mupen64plus-core folder and rerun this script."
		echo " "
		return 1
	  fi

	 cd mupen64plus-core
	 
	 mupen64plus_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$mupen64plus_core_patches" ]]; then
	  for patching in mupen64plus-core-patch*
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

      #update-alternatives --set gcc "/usr/local/bin/aarch64-linux-gnu-gcc-13"
      #update-alternatives --set g++ "/usr/local/bin/aarch64-linux-gnu-g++-13"

      if [[ "$bitness" == "32" ]]; then
        _opts='VULKAN=0 USE_GLES=1 NEON=1 VFP_HARD=1 OPTFLAGS="-O3" V=1 PIE=1 ACCURATE_FPU=1'
      else
        _opts='VULKAN=0 USE_GLES=1 NEW_DYNAREC=1 OPTFLAGS="-O3" V=1 PIE=1 ACCURATE_FPU=1'
      fi
      
      export CFLAGS="-mtune=cortex-a55 -flto=$(nproc) -fuse-linker-plugin"
      export CXXFLAGS="$CXXFLAGS $CFLAGS"
      export LDFLAGS="$CFLAGS"
      
      make -C "projects/unix" clean
	  make -j$(nproc) -C "projects/unix" $_opts all

	  if [[ $? != "0" ]]; then
	  	#update-alternatives --set gcc "/usr/bin/gcc-8"
	  	#update-alternatives --set g++ "/usr/bin/g++-8"
		echo " "
		echo "There was an error while building the newest mupen64plus-core standalone.  Stopping here."
		return 1
	  fi

	  #update-alternatives --set gcc "/usr/bin/gcc-8"
	  #update-alternatives --set g++ "/usr/bin/g++-8"

	  strip projects/unix/libmupen64plus.so.2.0.0

	  if [ ! -d "../mupen64plussa-$bitness/" ]; then
		mkdir -v ../mupen64plussa-$bitness
	  fi

	  cp projects/unix/libmupen64plus.so.2.0.0 ../mupen64plussa-$bitness/.
	  
	  echo " "
	  echo "mupen64plus-core executable has been placed in workspace/mupen64plussa-$bitness subfolder"

