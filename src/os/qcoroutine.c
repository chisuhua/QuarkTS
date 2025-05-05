/**
 * @file qcoroutine.c
 * @author J. Camilo Gomez C.
 * @note This file is part of the QuarkTS distribution.
 **/

#include "qcoroutine.h"

/*============================================================================*/
qBool_t qCR_ExternControl( qCR_Handle_t h,
                           const qCR_ExternAction_t action,
                           const qCR_ExtPosition_t pos )
{
    qBool_t retValue = qFalse;

    if ( NULL != h ) {
        retValue = qTrue;

        switch ( action ) {
            case qCR_RESTART:
                h->instr = (_qCR_TaskPC_t)_qCR_PC_INIT_VAL;
                break;
            case qCR_POSITION_SET:
                h->instr = pos;
                break;
            case qCR_SUSPEND:
                h->prev = h->instr;
                h->instr = (_qCR_TaskPC_t)_qCR_PC_SUSPENDED_VAL;
                break;
            case qCR_RESUME:
                if ( (_qCR_TaskPC_t)_qCR_UNDEFINED != h->prev ) {
                    h->instr = h->prev;
                }
                else {
                    h->instr = (_qCR_TaskPC_t)_qCR_PC_INIT_VAL;
                }
                h->prev = (_qCR_TaskPC_t)_qCR_UNDEFINED;
                break;
            default:
                retValue = qFalse;
                break;
        }
    }

    return retValue;
}
/*============================================================================*/
/* Used to perform the semaphores operations on Coroutines
Do not use this function explicitly to handle semaphores, use the provided
coroutine statements instead : <qCR_SemInit>, <qCR_SemWait> and <qCR_SemSignal>
*/
qBool_t _qCR_Sem( qCR_Semaphore_t * const sem,
                  const _qCR_Oper_t oper )
{
    qBool_t retValue = qFalse;

    if ( NULL != sem ) {
        switch ( oper ) {
            case _qCR_SEM_SIGNAL:
                ++sem->count;
                break;
            case _qCR_SEM_TRYLOCK:
                if ( sem->count > (size_t)0 ) {
                    retValue = qTrue; /*break the Wait operation*/
                    --sem->count;
                }
                break;
            default:
                if ( oper >= _qCR_UNDEFINED ) {
                    sem->count = (size_t)oper;
                }
                break;
        }
    }

    return retValue;
}
/*============================================================================*/
