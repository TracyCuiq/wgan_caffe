#!/bin/bash
################################################################################
# 
# * launch_wgan_caffe.sh
# * Copyright (C) 2017 Juan Maria Gomez Lopez <juanecitorr@gmail.com>
# *
# * caffe_network is free software: you can redistribute it and/or modify it
# * under the terms of the GNU General Public License as published by the
# * Free Software Foundation, either version 3 of the License, or
# * (at your option) any later version.
# *
# * caffe_wgan is distributed in the hope that it will be useful, but
# * WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# * See the GNU General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License along
# * with this program.  If not, see <http://www.gnu.org/licenses/>.
# */

#* @file launch_wgan_faces_caffe.sh
# * @author Juan Maria Gomez Lopez <juanecitorr@gmail.com>
# * @date 20 Aug 2017
# */

################################################################################

WGAN_BIN_FILE=./bin/wgan_release

# Learning rate in A models is base_lr: 0.0001
SOLVER_D_MODEL_A=./models/solver_d_lr_A.prototxt
SOLVER_G_MODEL_A=./models/solver_g_lr_A.prototxt

# Learning rate in B models is base_lr: 0.00001
SOLVER_D_MODEL_B=./models/solver_d_lr_B.prototxt
SOLVER_G_MODEL_B=./models/solver_g_lr_B.prototxt
SOLVER_G_STATE_B=./wgan_g_iter_780.solverstate

# Learning rate in C models is base_lr: 0.000001
SOLVER_D_MODEL_C=./models/solver_d_lr_C.prototxt
SOLVER_G_MODEL_C=./models/solver_g_lr_C.prototxt
SOLVER_G_STATE_C=./wgan_g_iter_1560.solverstate

SOLVER_D_STATE_D=./wgan_d_iter_58500.solverstate

BATCH_SIZE=64

ITER_D_BY_G=5
TOTAL_ITERS=780

TIMESTAMP=`date +%Y%m%d%H%M%S`
DATASET=LFW_faces
DATA_SOURCE_FOLDER_PATH=./bin/data/lfw_funneled
OUTPUT_FOLDER_PATH=wgan_faces_${TIMESTAMP}

Z_VECTOR_BIN_FILE=${OUTPUT_FOLDER_PATH}/z_vector.bin
Z_VECTOR_SIZE=100
LOG_FILE=${OUTPUT_FOLDER_PATH}/wgan_faces.log

################################################################################

. ./wgan_exports

mkdir -p ${OUTPUT_FOLDER_PATH}

if ! [ -f "${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_B}" ]; then
	${WGAN_BIN_FILE} --run-wgan --log ${LOG_FILE} --batch-size ${BATCH_SIZE} \
				--d-iters-by-g-iter ${ITER_D_BY_G} --main-iter ${TOTAL_ITERS} \
				--z-vector-bin-file ${Z_VECTOR_BIN_FILE} \
				--z-vector-size ${Z_VECTOR_SIZE} \
				--dataset ${DATASET} \
				--data-src-path ${DATA_SOURCE_FOLDER_PATH} \
				--output-path ${OUTPUT_FOLDER_PATH} \
				--solver-d-model ${SOLVER_D_MODEL_A} \
				--solver-g-model ${SOLVER_G_MODEL_A}
				
fi

SOLVER_D_STATE_B=`ls -1rt ${OUTPUT_FOLDER_PATH}/wgan_d_iter_*solverstate | tail -1`

if ! [ -f "${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_C}" ] && [ -f "${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_B}" ]; then
	${WGAN_BIN_FILE} --run-wgan --log ${LOG_FILE} --batch-size ${BATCH_SIZE} \
				--d-iters-by-g-iter ${ITER_D_BY_G} --main-iter ${TOTAL_ITERS} \
				--z-vector-bin-file ${Z_VECTOR_BIN_FILE} \
				--z-vector-size ${Z_VECTOR_SIZE} \
				--dataset ${DATASET} \
				--data-src-path ${DATA_SOURCE_FOLDER_PATH} \
				--output-path ${OUTPUT_FOLDER_PATH} \
				--solver-d-model ${SOLVER_D_MODEL_B} \
				--solver-g-model ${SOLVER_G_MODEL_B} \
				--solver-d-state ${OUTPUT_FOLDER_PATH}/${SOLVER_D_STATE_B} \
				--solver-g-state ${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_B}

fi

SOLVER_D_STATE_C=`ls -1rt ${OUTPUT_FOLDER_PATH}/wgan_d_iter_*solverstate | tail -1`

if ! [ -f "${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_D}" ] && [ -f "${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_C}" ]; then
	${WGAN_BIN_FILE} --run-wgan --log ${LOG_FILE} --batch-size ${BATCH_SIZE} \
				--d-iters-by-g-iter ${ITER_D_BY_G} --main-iter ${TOTAL_ITERS} \
				--z-vector-bin-file ${Z_VECTOR_BIN_FILE} \
				--z-vector-size ${Z_VECTOR_SIZE} \
				--dataset ${DATASET} \
				--data-src-path ${DATA_SOURCE_FOLDER_PATH} \
				--output-path ${OUTPUT_FOLDER_PATH} \
				--solver-d-model ${SOLVER_D_MODEL_C} \
				--solver-g-model ${SOLVER_G_MODEL_C} \
				--solver-d-state ${OUTPUT_FOLDER_PATH}/${SOLVER_D_STATE_C} \
				--solver-g-state ${OUTPUT_FOLDER_PATH}/${SOLVER_G_STATE_C}

fi

################################################################################

exit 0
