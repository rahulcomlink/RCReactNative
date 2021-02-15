// Comlink Communicator SDK
// Copyright 2019 Comlink Inc. All rights reserved.

/// \file
///
/// \addtogroup c-api The C API
/// @{
/// \addtogroup c-log The Logging API
/// @{
///

#ifndef CLOG_H_
#define CLOG_H_

#if defined(__cplusplus)
#define EXPORT extern "C"
#else
#define EXPORT
#endif

///
/// \brief Supported logging levels
///
typedef enum { CLOG_DEBUG, CLOG_INFO, CLOG_WARNING, CLOG_ERROR } CLOGLEVEL;

///
/// \brief The log writer function signature.
///
typedef void (*CLOGWRITER)(CLOGLEVEL level, const char* text);

///
/// \brief Sets the logging level.
///
/// \param level The desired logging level.
///
EXPORT void CLogSetLevel(CLOGLEVEL level);

///
/// \brief Sets the log writer.
///
/// \param writer The log writer function.
///
EXPORT void CLogSetWriter(CLOGWRITER writer);

#endif  // CLOG_H_