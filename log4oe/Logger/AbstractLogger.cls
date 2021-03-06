
 /*------------------------------------------------------------------------
    File        : AbstractLogger
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : Mark Abbott
    Created     : Wed May 30 14:47:00 BST 2018
    Notes       :
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING log4oe.Logger.ILogger.
USING log4oe.LogAppender.ILogAppender.
USING log4oe.LoggerConfig.ILoggerConfig.
USING log4oe.LogLevel.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS log4oe.Logger.AbstractLogger IMPLEMENTS ILogger ABSTRACT:

    DEFINE PROTECTED TEMP-TABLE ttAppender NO-UNDO
        FIELD Appender AS Progress.Lang.Object.


    DEFINE PROTECTED PROPERTY Config AS ILoggerConfig NO-UNDO
    PROTECTED GET.
    PROTECTED SET.
    
    DEFINE PRIVATE PROPERTY LoggerName AS CHARACTER NO-UNDO
    PRIVATE GET.
    PRIVATE SET.

    METHOD PUBLIC VOID addLogAppender(INPUT poAppender AS ILogAppender):

        IF  VALID-OBJECT(poAppender)
        AND NOT CAN-FIND(FIRST ttAppender
                         WHERE ttAppender.Appender = poAppender) THEN
        DO:
            CREATE ttAppender.
            ASSIGN ttAppender.Appender = poAppender.
        END.

    END METHOD.

    METHOD PUBLIC VOID setLoggerConfig(INPUT poLoggerConfig AS ILoggerConfig):

        IF VALID-OBJECT(poLoggerConfig) THEN
        DO:
            ASSIGN Config = poLoggerConfig.
        END.

    END METHOD.

    METHOD PUBLIC ILoggerConfig getLoggerConfig():
        RETURN Config.
    END METHOD.
    
    METHOD PUBLIC VOID setLoggerName(INPUT pcLoggerName AS CHARACTER):
        
        IF pcLoggerName NE "" AND pcLoggerName NE ? THEN
        DO:
            ASSIGN LoggerName = TRIM(pcLoggerName).
        END.
        
    END METHOD.
    
    METHOD PUBLIC CHARACTER getLoggerName():
        RETURN LoggerName.
    END METHOD.

    METHOD PUBLIC VOID Log( INPUT piLogLevel AS INTEGER, INPUT pcMessage AS CHARACTER ):

        DEFINE VARIABLE voAppender AS ILogAppender NO-UNDO.

        IF ShouldLog(piLogLevel) THEN
        DO:

            FOR EACH ttAppender EXCLUSIVE-LOCK:

                IF VALID-OBJECT(ttAppender.Appender) AND ttAppender.Appender:GetClass():IsA("log4oe.LogAppender.ILogAppender") THEN
                DO:
                    ASSIGN voAppender = CAST(ttAppender.Appender, "log4oe.LogAppender.ILogAppender") NO-ERROR.

                    IF VALID-OBJECT(voAppender) THEN
                    DO:
                        voAppender:Log(piLogLevel, pcMessage).
                    END.
                END.
                ELSE
                DO:
                    // Invalid Appender so remove from list
                    DELETE OBJECT ttAppender.Appender NO-ERROR.
                    DELETE ttAppender.
                END.

            END.
        END.

    END METHOD.

    METHOD PUBLIC VOID Log( INPUT piLogLevel AS INTEGER, INPUT peError AS Progress.Lang.Error ):

        DEFINE VARIABLE voAppender AS ILogAppender NO-UNDO.

        IF ShouldLog(piLogLevel) THEN
        DO:

            FOR EACH ttAppender EXCLUSIVE-LOCK:

                IF VALID-OBJECT(ttAppender.Appender) AND ttAppender.Appender:GetClass():IsA("log4oe.LogAppender.ILogAppender") THEN
                DO:
                    ASSIGN voAppender = CAST(ttAppender.Appender, "log4oe.LogAppender.ILogAppender") NO-ERROR.

                    IF VALID-OBJECT(voAppender) THEN
                    DO:
                        voAppender:Log(piLogLevel, peError).
                    END.
                END.
                ELSE
                DO:
                    // Invalid Appender so remove from list
                    DELETE OBJECT ttAppender.Appender NO-ERROR.
                    DELETE ttAppender.
                END.

            END.
        END.

    END METHOD.

    METHOD PUBLIC VOID TRACE (INPUT pcMessage AS CHARACTER):
        THIS-OBJECT:Log(INPUT LogLevel:TRACE, INPUT pcMessage).
    END METHOD.

    METHOD PUBLIC VOID TRACE (INPUT peError AS Progress.Lang.Error):
        THIS-OBJECT:Log(INPUT LogLevel:TRACE, INPUT peError).
    END METHOD.

    METHOD PUBLIC VOID DEBUG (INPUT pcMessage AS CHARACTER):
        THIS-OBJECT:Log(INPUT LogLevel:DEBUG, INPUT pcMessage).
    END METHOD.

    METHOD PUBLIC VOID DEBUG (INPUT peError AS Progress.Lang.Error):
        THIS-OBJECT:Log(INPUT LogLevel:DEBUG, INPUT peError).
    END METHOD.

    METHOD PUBLIC VOID INFO (INPUT pcMessage AS CHARACTER):
        THIS-OBJECT:Log(INPUT LogLevel:INFO, INPUT pcMessage).
    END METHOD.

    METHOD PUBLIC VOID INFO (INPUT peError AS Progress.Lang.Error):
        THIS-OBJECT:Log(INPUT LogLevel:INFO, INPUT peError).
    END METHOD.

    METHOD PUBLIC VOID WARN (INPUT pcMessage AS CHARACTER):
        THIS-OBJECT:Log(INPUT LogLevel:WARN, INPUT pcMessage).
    END METHOD.

    METHOD PUBLIC VOID WARN (INPUT peError AS Progress.Lang.Error):
        THIS-OBJECT:Log(INPUT LogLevel:WARN, INPUT peError).
    END METHOD.

    METHOD PUBLIC VOID ERROR (INPUT pcMessage AS CHARACTER):
        THIS-OBJECT:Log(INPUT LogLevel:ERROR, INPUT pcMessage).
    END METHOD.

    METHOD PUBLIC VOID ERROR (INPUT peError AS Progress.Lang.Error):
        THIS-OBJECT:Log(INPUT LogLevel:ERROR, INPUT peError).
    END METHOD.

    METHOD PUBLIC VOID FATAL (INPUT pcMessage AS CHARACTER):
        THIS-OBJECT:Log(INPUT LogLevel:FATAL, INPUT pcMessage).
    END METHOD.

    METHOD PUBLIC VOID FATAL (INPUT peError AS Progress.Lang.Error):
        THIS-OBJECT:Log(INPUT LogLevel:FATAL, INPUT peError).
    END METHOD.

    METHOD PROTECTED LOGICAL ShouldLog (INPUT piLogLevel AS INTEGER):
        RETURN piLogLevel <= Config:getLogLevel().
    END METHOD.

END CLASS.