#
# Common variables used in scripts that pull remote config data.
#
# All scripts in this directory should source this file.
#

source $(dirname $0)/../../config

# Remote Server with config data
export DEPLOY_SRV="ec-deploy-01.ec2.rallydev.com"
# Location of remote config files to pull latest from
export DEPLOY_URL="http://${DEPLOY_SRV}/reset_config"
# Location of local config files
export LOCAL_CONFIG_DIR="$(dirname $0)/../../cache"


# Function to load given config file from remote server
# Parameters: $1 - name of config file e.g. feature_toggles.config
function load_config() {

  config_filename=$1
  local_config="${LOCAL_CONFIG_DIR}/${config_filename}"
  deploy_config="${DEPLOY_URL}/${config_filename}"

  if [ -z "${config_filename}" ]; then
    echo "Error: No config filename given.  Aborting..."
    exit 1
  fi

  echo -n "Pulling down remote config file... "
  wget -q $deploy_config --output-document=$local_config.tmp
  echo "Done"
  echo "  > Retrieved '${deploy_config}'"

  # only replace config file if a new one was retreived
  if [ -f "${local_config}.tmp" ]; then
    echo -n "Replacing previous config file... "
    mv ${local_config}.tmp ${local_config}
    echo "Done"
    echo "  > Created '${local_config}'"
  else
    echo "WARNING: Error retrieving remote file.  Will use existing config."
    if [ ! -f "${local_config}" ]; then
      echo "ERROR: Local config file ${local_config} does not exist. Aborting..."
      exit 1
    fi
  fi;

  if [ ! -f "${local_config}" ]; then
    echo "Error: No config file [${local_config}] found. Aborting..."
    exit 1
  fi

  # !!! These CONFIGS vars are available to caller and contains loaded data
  # - format: space separated list of name|value pairs
  # - omit comment lines ('#')
  export CONFIGS=$(sed -e '/^#.*$/d' ${local_config})
  export NUM_CONFIGS=$(sed -e '/^#.*$/d' ${local_config} | wc -l)
}
