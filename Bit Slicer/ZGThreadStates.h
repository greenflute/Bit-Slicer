/*
 * Copyright (c) 2014 Mayur Pawashe
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef Bit_Slicer_ZGThreadStates_h
#define Bit_Slicer_ZGThreadStates_h

#include "ZGMemoryTypes.h"
#include "ZGProcessTypes.h"

#include <machine/_mcontext.h> // this header is needed when modules are enabled
#include <mach/message.h>
#include <mach/thread_act.h>
#include <stdbool.h>
#include <TargetConditionals.h>

#if TARGET_CPU_ARM64
typedef arm_neon_state64_t zg_vector_state_t;
typedef arm_thread_state64_t zg_thread_state_t;
typedef arm_exception_state64_t zg_exception_state_t;
typedef arm_debug_state64_t zg_debug_state_t;
typedef arm_state_hdr_t zg_state_hdr_t;
typedef arm_thread_state32_t zg_thread_state32_t;
typedef arm_thread_state64_t zg_thread_state64_t;
#else
typedef x86_avx_state_t zg_vector_state_t;
typedef x86_thread_state_t zg_thread_state_t;
typedef x86_debug_state_t zg_debug_state_t;
typedef x86_state_hdr_t zg_state_hdr_t;
typedef x86_thread_state32_t zg_thread_state32_t;
typedef x86_thread_state64_t zg_thread_state64_t;
#endif

bool ZGGetGeneralThreadState(zg_thread_state_t *threadState, thread_act_t thread, mach_msg_type_number_t *stateCount);
bool ZGSetGeneralThreadState(zg_thread_state_t *threadState, thread_act_t thread, mach_msg_type_number_t stateCount);

#if TARGET_CPU_ARM64
bool ZGGetExceptionThreadState(zg_exception_state_t *exceptionState, thread_act_t thread, mach_msg_type_number_t *stateCount);
#endif

ZGMemoryAddress ZGInstructionPointerFromGeneralThreadState(zg_thread_state_t *threadState, ZGProcessType type);
void ZGSetInstructionPointerFromGeneralThreadState(zg_thread_state_t *threadState, ZGMemoryAddress instructionAddress, ZGProcessType type);

ZGMemoryAddress ZGBasePointerFromGeneralThreadState(zg_thread_state_t *threadState, ZGProcessType type);

bool ZGGetDebugThreadState(zg_debug_state_t *debugState, thread_act_t thread, mach_msg_type_number_t *stateCount);
bool ZGSetDebugThreadState(zg_debug_state_t *debugState, thread_act_t thread, mach_msg_type_number_t stateCount);

bool ZGGetVectorThreadState(zg_vector_state_t *vectorState, thread_act_t thread, mach_msg_type_number_t *stateCount, ZGProcessType type, bool *hasAVXSupport);
bool ZGSetVectorThreadState(zg_vector_state_t *vectorState, thread_act_t thread, mach_msg_type_number_t stateCount, ZGProcessType type);

#endif
