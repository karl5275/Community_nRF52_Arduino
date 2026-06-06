# Holyiot YJ-18010 (nRF52840)

Arduino variant for the Holyiot YJ-18010 nRF52840 module.

## Unlocking / erasing the chip

The unlock and erase programmers in this BSP work on the YJ-18010 even though
they were originally added for the BlueMacro (EBYTE E73-2G4M08S1C) board. Both
are nRF52840 modules, and the unlock/erase commands operate at the chip level
over SWD — they do not reference anything board- or variant-specific:

- **`J-Link - Unlock Only`** (`nrfjprog --recover -f nrf52`) — the proper unlock
  for a locked chip: disables APPROTECT/readback protection and mass-erases.
- **`Black Magic Probe - Unlock+Erase Only`** (`mon erase_mass`) — wipes flash
  and clears protection on most nRF52 targets.

The only requirements are physical, not software:

1. Reach **SWDIO**, **SWDCLK**, and **GND** (plus target **VCC**) on the
   module's pads/castellations.
2. Power/reference the target correctly — `mon tpwr enable` supplies 3.3 V from a
   Black Magic Probe; with a J-Link, make sure the target is powered.

### How to run it (Arduino IDE)

1. **Tools → Board** → *Holyiot 18010 (nRF52840)*
2. **Tools → Programmer** → the unlock/erase entry above
3. **Tools → Burn Bootloader** to execute the programmer's command

After unlocking, reflash with **`Black Magic Probe for nRF52 (MBR+SD+Bootloader)`**
(`bmp_boot_full`) or the J-Link bootloader programmer to restore the MBR,
SoftDevice (s140 6.1.1) and bootloader.

> Tip: `nrfjprog --recover` (J-Link) is the most reliable unlock for a fully
> APPROTECT-locked nRF52840. If BMP `mon erase_mass` fails on a locked part, fall
> back to the J-Link recover path.
