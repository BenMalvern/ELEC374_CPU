# Project Setup Instructions

This repository must be cloned into the Intel FPGA Lite 18.1 directory structure in order for Quartus project paths to resolve correctly.

## Cloning the Repository

### Recommended Directory Structure

The expected base path is:

C:\intelFPGA_lite\18.1\elec374\

If the `elec374` folder does not already exist under the `18.1` directory, you must create it manually before cloning the repository.

### Steps

1. Navigate to the Intel FPGA Lite 18.1 installation directory:

   C:\intelFPGA_lite\18.1\

2. Create a new folder named:

   elec374

3. Open a terminal (Command Prompt, PowerShell, or Git Bash).

4. Change into the `elec374` directory:

   cd C:\intelFPGA_lite\18.1\elec374

5. Clone the repository:

   git clone <REPO_URL>

After cloning, the project should be located at:

C:\intelFPGA_lite\18.1\elec374\<repository-name>

## Alternative: Existing Workspace

If you already have a workspace created under:

C:\intelFPGA_lite\18.1\

you may clone this repository directly into that existing workspace instead of creating a new `elec374` folder.

## Notes

- Quartus Prime projects rely on relative paths; placing the repository under the `18.1` directory is required.
- Ensure that **Quartus Prime Lite version 18.1** is installed before opening the project.
