#!/bin/sh
# =======================================================================================
#
# This script will create, setup and build a single-site simulation for the BCI on chicoma
# project 
# Based off Ryan Knoxes script for BCI 
#
# USER SETTINGS
# USER MAY ALSO WANT TO ADJUST XML CHANGES, AND NAMELIST ARGUMENTS
# =====================================================================================
export user=zjrobbins
export TAG='PNM_test'                               # User defined tag to differentiate runs
export COMPSET=IELMFATES                                  # Compset (probably ICLM45ED or ICLM50ED)
export MAC=chicoma                                        # Name your machine
export COMPILER=gnu                                       # Name your compiler
export FUNDING=t24_forecast
export FATES_PARAM=BCI_updated_52924.nc                              # Name of FATES parameter file in S_CA_FATES/params/
export SITE_BASE_DIR=/lustre/scratch5/.mdt1/$user/E3SM_cases # Where is the site folder located? (SITE_NAME)
export DATA_DIR=/lustre/scratch5/.mdt1/$user/Panama_precip/            # Where are the parameter and climate drivers located.
export DIN_LOC_ROOT=/usr/projects/cesm/input_data              #location of external input data, YOU will need access to veg. 
export CLM_USRDAT_DOMAIN=domain_bci_panama_v1_c171113.nc       # Name of domain file in  $DATA_DIR/params/
export CLM_USRDAT_SURDAT=surfdata_bci_panama_v1_c171113.3898.nc # Name of surface file in $DATA_DIR/params/

######Change this to veg E3SM on chonggangs script
export ES3M_ROOT=/lustre/scratch5/.mdt1/zjrobbins/API25_2/E3SM

# DEPENDENT PATHS AND VARIABLES (USER MIGHT CHANGE THESE..)
# =======================================================================================
export CASEROOT=${SITE_BASE_DIR}                               # Where the build is generated (probably on scratch partition)
export CLM_SURFDAT_DIR=${DATA_DIR}/Gen_needs/BCI/
export CLM_DOMAIN_DIR=${DATA_DIR}/Gen_needs/BCI/
export FATES_PARAM_DIR=${DATA_DIR}/params #location of FATES paameter files
export DIN_LOC_ROOT_FORCE=${DATA_DIR}/Gen_needs/BCI/Clim/bci_0.1x0.1_met.v6.1/  #location of climate forcing, not including the SITE_NAMES
export CLM_HASH=`cd ${E3SM_ROOT}/components/elm/;git log -n 1 --pretty=%h`
export FATES_HASH=`(cd ${E3SM_ROOT}/components/elm/src/external_models/fates;git log -n 1 --pretty=%h)`
export GIT_HASH=C${CLM_HASH}-F${FATES_HASH}
export RES=ELM_USRDAT
export CASE_NAME=${TAG}.${COMPSET}

# export USRDAT_METFORCE_NAME=${SITE_DIR} (DEPRECATED?)


# REMOVE EXISTING CASE IF PRESENT
rm -r ${CASEROOT}/${CASE_NAME}

# CREATE THE CASE
#### Need to change this to CXs version 
${ES3M_ROOT}/cime/scripts/create_newcase -case ${CASEROOT}/${CASE_NAME} -res ${RES} -compset ${COMPSET} -mach ${MAC} -project ${FUNDING} -compiler ${COMPILER} -mpilib="mpi-serial"

cd ${CASEROOT}/${CASE_NAME} 


# SET PATHS TO SCRATCH ROOT, DOMAIN AND MET DATA (USERS WILL PROB NOT CHANGE THESE)
# =================================================================================
./xmlchange -file env_run.xml -id DIN_LOC_ROOT -val ${DIN_LOC_ROOT}
./xmlchange -file env_run.xml -id ATM_DOMAIN_FILE -val ${CLM_USRDAT_DOMAIN}
./xmlchange -file env_run.xml -id ATM_DOMAIN_PATH -val ${CLM_DOMAIN_DIR}
./xmlchange -file env_run.xml -id LND_DOMAIN_FILE -val ${CLM_USRDAT_DOMAIN}
./xmlchange -file env_run.xml -id LND_DOMAIN_PATH -val ${CLM_DOMAIN_DIR}
./xmlchange -file env_run.xml -id DATM_MODE -val CLM1PT
./xmlchange -file env_run.xml -id ELM_USRDAT_NAME -val ${SITE_NAME}
./xmlchange -file env_run.xml -id DIN_LOC_ROOT_CLMFORC -val ${DIN_LOC_ROOT_FORCE}
#./xmlchange -file env_build.xml -id CESMSCRATCHROOT -val ${CASE_NAME}

# SPECIFY PE LAYOUT FOR SINGLE SITE RUN (USERS WILL PROB NOT CHANGE THESE)
# =================================================================================

./xmlchange NTASKS_ATM=1
./xmlchange NTASKS_CPL=1
./xmlchange NTASKS_GLC=1
./xmlchange NTASKS_OCN=1
./xmlchange NTASKS_WAV=1
./xmlchange NTASKS_ICE=1
./xmlchange NTASKS_LND=1
./xmlchange NTASKS_ROF=1
./xmlchange NTASKS_ESP=1
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=0
./xmlchange ROOTPE_GLC=0
./xmlchange ROOTPE_OCN=0
./xmlchange ROOTPE_WAV=0
./xmlchange ROOTPE_ICE=0
./xmlchange ROOTPE_LND=0
./xmlchange ROOTPE_ROF=0
./xmlchange ROOTPE_ESP=0
./xmlchange NTHRDS_ATM=1
./xmlchange NTHRDS_CPL=1
./xmlchange NTHRDS_GLC=1
./xmlchange NTHRDS_OCN=1
./xmlchange NTHRDS_WAV=1
./xmlchange NTHRDS_ICE=1
./xmlchange NTHRDS_LND=1
./xmlchange NTHRDS_ROF=1
./xmlchange NTHRDS_ESP=1

# SPECIFY RUN TYPE PREFERENCES (USERS WILL CHANGE THESE)
# =================================================================================
./xmlchange PIO_VERSION=2
./xmlchange -file env_build.xml -id DEBUG -val FALSE
./xmlchange -file env_run.xml -id STOP_N -val 11
./xmlchange -file env_run.xml -id RUN_STARTDATE -val '2013-01-01'
./xmlchange -file env_run.xml -id STOP_OPTION -val nyears
./xmlchange -file env_run.xml -id REST_N -val 1
./xmlchange -file env_run.xml -id DATM_CLMNCEP_YR_START -val 2013
./xmlchange -file env_run.xml -id DATM_CLMNCEP_YR_END -val 2024


# MACHINE SPECIFIC, AND/OR USER PREFERENCE CHANGES (USERS WILL CHANGE THESE)
# =================================================================================

#./xmlchange -file env_build.xml -id GMAKE -val make
#./xmlchange -file env_run.xml -id BATCHQUERY -val ''
#./xmlchange -file env_run.xml -id BATCHSUBMIT -val ''
#./xmlchange -file env_run.xml -id DOUT_S_SAVE_INTERIM_RESTART_FILES -val TRUE
#./xmlchange -file env_run.xml -id DOUT_S -val TRUE
#./xmlchange -file env_run.xml -id DOUT_S_ROOT -val '$CASEROOT/run'
#./xmlchange -file env_run.xml -id RUNDIR -val ${CASE_NAME}/run
#./xmlchange -file env_build.xml -id EXEROOT -val ${CASE_NAME}/bld

# MODIFY THE CLM NAMELIST (USERS MODIFY AS NEEDED)

cat >> user_nl_elm <<EOF
fsurdat = '${CLM_SURFDAT_DIR}/${CLM_USRDAT_SURDAT}'
fates_paramfile = '${FATES_PARAM_DIR}/${FATES_PARAM}'
hist_empty_htapes = .false.
!use_fates_inventory_init = .true.
!fates_inventory_ctrl_filename = '${SITE_BASE_DIR}/bci_inv_file_list.txt'
!hist_fincl1='NEP','NPP','GPP','TLAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR','HR','ED_biomass','ED_bleaf','ED_balive','DDBH_SCPF','BA_SCPF','NPLANT_SCPF','M1_SCPF','M2_SCPF','M3_SCPF','M4_SCPF','M5_SCPF','M6_SCPF'
EOF

# Usefull user_nl_clm arguments: 
# This couplet will enable hourly output
# hist_mfilt             = 480      
# hist_nhtfrq            = -1  
# hist_fincl1='NEP','NPP','GPP','TLAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR','HR','ED_biomass','ED_bleaf','ED_balive','DDBH_SCPF','BA_SCPF','NPLANT_SCPF','M1_SCPF','M2_SCPF','M3_SCPF','M4_SCPF','M5_SCPF','M6_SCPF','WIND','ZBOT','FSDS','RH','TBOT','PBOT','QBOT','RAIN','FLDS'

# MODIFY THE DATM NAMELIST (DANGER ZONE - USERS BEWARE CHANGING)

cat >> user_nl_datm <<EOF
taxmode = "cycle", "cycle", "cycle"
EOF

./case.setup

# HERE WE NEED TO MODIFY THE STREAM FILE (DANGER ZONE - USERS BEWARE CHANGING)
./preview_namelists
cp /lustre/scratch5/.mdt1/${user}/E3SM/scratch/${CASE_NAME}/run/datm.streams.txt.CLM1PT.ELM_USRDAT user_datm.streams.txt.CLM1PT.ELM_USRDAT
`sed -i '/FLDS/d' user_datm.streams.txt.CLM1PT.ELM_USRDAT`
`sed -i 's/CLM1PT_data/bci_0.1x0.1_met.v4_pio2/' user_datm.streams.txt.CLM1PT.ELM_USRDAT`

./case.build


