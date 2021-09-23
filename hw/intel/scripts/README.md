# Scripts for generating HW Designs for Intel FPGAs

# Execute the scripts (as necessary) in the following order:

# Source settings (you may modify the destination for your new project)
source ./init.sh

# Create new project
source ./create-new-project-copy.sh

# Compile static region
source ./compile-static-region.sh

# Create new HLS module from template and add it as new persona
source ./add-persona.sh PERSONA_NAME HLS_PROJECT_DIR
# Please replace "PERSONA_NAME" with a unique name of your choosing
# and provide the Path to the compiled HLS Project

# Compile persona (pr region)
source ./compile-pr-region.sh PERSONA_NAME

# Upload static bitstream. (This will perform a pci rescan.)
source ./upload-static-bitstream.sh

# Upload persona bitstream
source ./upload-persona-bitstream.sh PERSONA_NAME

# Finally have a look at test-pr-id.sh...
