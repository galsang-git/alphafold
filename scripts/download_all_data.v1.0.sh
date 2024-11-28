#!/bin/bash
#
# Copyright 2021 DeepMind Technologies Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Downloads and unzips all required data for AlphaFold.
#
# Usage: bash download_all_data.sh /path/to/download/directory

set -e

if [[ $# -eq 0 ]]; then
  echo "Error: download directory must be provided as an input argument."
  exit 1
fi

if ! command -v aria2c &> /dev/null ; then
  echo "Error: aria2c could not be found. Please install aria2c (sudo apt install aria2)."
  exit 1
fi

DOWNLOAD_DIR="$1"
DOWNLOAD_MODE="${2:-full_dbs}"  # Default mode to full_dbs.
if [[ "${DOWNLOAD_MODE}" != full_dbs && "${DOWNLOAD_MODE}" != reduced_dbs ]]
then
  echo "DOWNLOAD_MODE ${DOWNLOAD_MODE} not recognized."
  exit 1
fi

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Function to download and check status
download_data() {
  echo "Downloading $1..."
  bash "${SCRIPT_DIR}/$1.sh" "${DOWNLOAD_DIR}" &
}

echo "Downloading AlphaFold parameters..."
download_data "download_alphafold_params"

if [[ "${DOWNLOAD_MODE}" = reduced_dbs ]] ; then
  echo "Downloading Small BFD..."
  download_data "download_small_bfd"
else
  echo "Downloading BFD..."
  download_data "download_bfd"
fi

echo "Downloading MGnify..."
download_data "download_mgnify"

echo "Downloading PDB70..."
download_data "download_pdb70"

echo "Downloading PDB mmCIF files..."
download_data "download_pdb_mmcif"

echo "Downloading Uniref30..."
download_data "download_uniref30"

echo "Downloading Uniref90..."
download_data "download_uniref90"

echo "Downloading UniProt..."
download_data "download_uniprot"

echo "Downloading PDB SeqRes..."
download_data "download_pdb_seqres"

# Wait for all background jobs to finish
wait

echo "All data downloaded."
