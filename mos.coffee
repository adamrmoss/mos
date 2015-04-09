#!/usr/bin/env coffee

child_process = require 'child_process'
program = require 'commander'

executeCommand = (commandLine)->
  console.log('Executing: ' + commandLine)
  child_process.execSync commandLine

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
    executeCommand 'hdiutil detach /Volumes/mos16'

program
  .command 'build'
  .description 'Build Mos'
  .action (env, options)->
    console.log 'Building Mos...'
    executeCommand 'dd if=disks/mos16.img of=build/boot-record bs=1 skip=3 count=33'
    executeCommand 'nasm -f bin source/boot16.asm -o build/boot16'
    executeCommand 'dd if=build/boot-record of=build/boot16 bs=1 count=33 seek=3'
    executeCommand 'dd if=build/boot16 of=disks/mos16.img conv=notrunc'

program
  .parse process.argv
