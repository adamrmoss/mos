#!/usr/bin/env coffee

child_process = require 'child_process'
program = require 'commander'

executeCommand = (commandLine)->
  child_process.exec commandLine, {}, (error)->
    if error
      console.log 'ERROR: ' + error
      process.exit
    else
      console.log 'Done'

program
  .command 'boot'
  .description 'Boot up Mos'
  .action (env, options)->
    console.log 'Booting Mos...'
    executeCommand 'qemu-system-i386 -m 1 -fda disks/mos16.img -boot a'

program
  .command 'dos'
  .description 'Boot up DOS 3.3'
  .action (env, options)->
    console.log 'Booting DOS 3.3...'
    executeCommand 'qemu-system-i386 -m 1 -fda disks/dos3.3.img -boot a'

program
  .command 'mount'
  .description 'Mount the Floppy Disk Image to OSX'
  .action (env, options)->
    console.log 'Mounting Mos Floppy Disk...'
    executeCommand 'hdiutil attach disks/mos16.img'

program
  .command 'umount'
  .description 'Unmount the Floppy Disk Image from OSX'
  .action (env, options)->
    console.log 'Unmounting Mos Floppy Disk...'
    executeCommand 'hdiutil detach /Volumes/MOS'

program
  .command 'build'
  .description 'Build Mos'
  .action (env, options)->
    console.log 'Building Mos...'
    executeCommand 'nasm -f bin source/kernel16.asm -o build/kernel16'

program
  .command 'deploy'
  .description 'Copy Mos to the mounted Floppy Disk'
  .action (env, options)->
    console.log 'Deploying Mos...'
    executeCommand 'cp build/kernel /Volumes/MOS/mos'

program
  .parse process.argv
