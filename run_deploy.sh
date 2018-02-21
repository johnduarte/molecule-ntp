#!/bin/bash
# Dirty hack to install venv for molecule and run molecule test 'suite'.

# vars
WORKING_DIR="$HOME/workingdir"
VENV_NAME=venv-molecule
TEST_SOURCE_BASE=https://github.com/johnduarte
TEST_SOURCE=molecule-ntp
TEST_SOURCE_REPO="${TEST_SOURCE_BASE}/${TEST_SOURCE}"
TEST_BRANCH=rpc-glue
CONSTRAINTS="${WORKING_DIR}/${TEST_SOURCE}/constraints.txt"
REQUIREMENTS="${WORKING_DIR}/${TEST_SOURCE}/requirements.txt"
INVENTORY="/opt/openstack-ansible/playbooks/inventory"

# clone molecule test prototype
mkdir ${WORKING_DIR}
pushd ${WORKING_DIR}

git clone ${TEST_SOURCE_REPO}

# checkout appropriate branch
pushd ${TEST_SOURCE}
git checkout ${TEST_BRANCH}
popd

# create virtualenv for molecule
virtualenv --no-pip --no-setuptools --no-wheel ${VENV_NAME}

# activate virtualenv
source ${VENV_NAME}/bin/activate

# ensure that correct pip version is installed
PIP_TARGET="$(awk -F= '/^pip==/ {print $3}' ${CONSTRAINTS})"
VENV_PYTHON="${VENV_NAME}/bin/python"
VENV_PIP="${VENV_NAME}/bin/pip"

if [[ "$(${VENV_PIP} --version)" != "pip ${PIP_TARGET}"* ]]; then
    CURL_CMD="curl --silent --show-error --retry 5"
    OUTPUT_FILE="get-pip.py"
    ${CURL_CMD} https://bootstrap.pypa.io/get-pip.py > ${OUTPUT_FILE}  \
        || ${CURL_CMD} https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py > ${OUTPUT_FILE}
    GETPIP_OPTIONS="pip setuptools wheel --constraint ${CONSTRAINTS}"
    ${VENV_PYTHON} ${OUTPUT_FILE} ${GETPIP_OPTIONS} \
        || ${VENV_PYTHON} ${OUTPUT_FILE} --isolated ${GETPIP_OPTIONS}
fi

# install test suite requirements
PIP_OPTIONS="-c ${CONSTRAINTS} -r ${REQUIREMENTS}"
${VENV_PIP} install ${PIP_OPTIONS} || ${VENV_PIP} install --isolated ${PIP_OPTIONS}

# generate moleculerized inventory from osa dynamic inventory
if [ ! -d ${INVENTORY} ]; then
    echo "ERROR: The rpc-o dynamic inventory is not present" 1>&2
    exit 1
fi
${INVENTORY}/dynamic_inventory.py > ${WORKING_DIR}/dynamic_inventory.json
if [ ! -f ${WORKING_DIR}/dynamic_inventory.json ]; then
    echo "ERROR: The dynamic inventory json file is not present" 1>&2
    exit 1
fi

pushd ${TEST_SOURCE}
./moleculerize.py --output molecule/default/molecule.yml ${WORKING_DIR}/dynamic_inventory.json

# run molecule anisble-playbook with osa inventory
export ANSIBLE_HOST_KEY_CHECKING=False

molecule converge
molecule verify
popd

popd
