#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <math.h>
#include "QuarkTS.h"


#define SIGNAL_BUTTON_PRESSED   ( (qSM_SigId_t)1 )
#define SIGNAL_TIMEOUT          (QSM_SIGNAL_TIMEOUT(0))
#define SIGNAL_BLINK            (QSM_SIGNAL_TIMEOUT(1))

qTask_t LED_Task; /*The task node*/
qSM_t LED_FSM; /*The state-machine handler*/
qSM_State_t State_LEDOff, State_LEDOn, State_LEDBlink;
qQueue_t LEDsigqueue; /*the signal-queue*/ 
qSM_Signal_t led_sig_stack[5];  /*the signal-queue storage area*/


qSM_Status_t DoorClosed_State( qSM_Handler_t h );
qSM_Status_t DoorOpen_State( qSM_Handler_t h );

qSM_Status_t Heating_State( qSM_Handler_t h );
qSM_Status_t Off_State( qSM_Handler_t h );

qSM_Status_t Toasting_State( qSM_Handler_t h );
qSM_Status_t Baking_State( qSM_Handler_t h );

qSM_Transition_t LEDOff_transitions[] = {
    { SIGNAL_BUTTON_PRESSED, NULL, &State_LEDOn    ,0, NULL }
};

qSM_Transition_t LEDOn_transitions[] = {
    { SIGNAL_TIMEOUT,        NULL, &State_LEDOff   ,0, NULL },
    { SIGNAL_BUTTON_PRESSED, NULL, &State_LEDBlink ,0, NULL }
};

qSM_Transition_t LEDBlink_transitions[] = {
    { SIGNAL_TIMEOUT,        NULL, &State_LEDOff   ,0, NULL },
    { SIGNAL_BUTTON_PRESSED, NULL, &State_LEDOff   ,0, NULL }
};

qSM_TimeoutStateDefinition_t LedOn_Timeouts[]={
    { 10.0f,  QSM_TSOPT_INDEX(0) | QSM_TSOPT_SET_ENTRY | QSM_TSOPT_RST_EXIT  },
};

qSM_TimeoutStateDefinition_t LEDBlink_timeouts[]={
    { 10.0f,  QSM_TSOPT_INDEX(0) | QSM_TSOPT_SET_ENTRY | QSM_TSOPT_RST_EXIT  },
    { 0.5f,   QSM_TSOPT_INDEX(1) | QSM_TSOPT_SET_ENTRY | QSM_TSOPT_RST_EXIT | QSM_TSOPT_PERIODIC  },
};
/*---------------------------------------------------------------------*/
qSM_Status_t State_LEDOff_Callback( qSM_Handler_t h ){
    switch( h->Signal ){
        case QSM_SIGNAL_ENTRY:
            puts("->ledoff");
            //BSP_LED_OFF();
            break;
        case QSM_SIGNAL_EXIT:
            puts("x-ledoff");
            break;   
        default:
            break;
    }
    return qSM_STATUS_EXIT_SUCCESS;
}
/*---------------------------------------------------------------------*/
qSM_Status_t State_LEDOn_Callback( qSM_Handler_t h ){
    switch( h->Signal ){
        case QSM_SIGNAL_ENTRY:
            puts("->ledon");
            //BSP_LED_ON();
            break;
        case QSM_SIGNAL_EXIT:
            puts("x-ledon");
            break;
        default:
            break;
    }
    return qSM_STATUS_EXIT_SUCCESS;
}
/*---------------------------------------------------------------------*/
qSM_Status_t State_LEDBlink_Callback( qSM_Handler_t h ){
    switch( h->Signal ){
        case QSM_SIGNAL_ENTRY:
            puts("->ledblink");
            break;
        case QSM_SIGNAL_EXIT:
            puts("x-ledblink");
            break; 
        case SIGNAL_BLINK:
            puts("LED TOGGLE");
            break;
    }
    return qSM_STATUS_EXIT_SUCCESS;
}
/*===========================Reference clock for the kernel===================*/
qClock_t GetTickCountMs(void){ /*get system background timer (1mS tick)*/
    struct timespec ts;
    //clock_gettime(CLOCK_MONOTONIC, &ts);
    return (qClock_t)(ts.tv_nsec / (qClock_t)1000000uL) + ((qClock_t)ts.tv_sec * (qClock_t)1000uL);
}

/*=============================================================================*/
void start() {  
    qSM_TimeoutSpec_t tm_spectimeout;

    //printf("OvenControl = %d\r\n", getpid() );
    qOS_Setup(GetTickCountMs, 0.001f, NULL ); 

    qStateMachine_Setup( &LED_FSM, NULL, &State_LEDOff, NULL, NULL ); 
    qStateMachine_StateSubscribe( &LED_FSM, &State_LEDOff, NULL, State_LEDOff_Callback, NULL, qFalse ); 
    qStateMachine_StateSubscribe( &LED_FSM, &State_LEDOn, NULL, State_LEDOn_Callback, NULL, qFalse );
    qStateMachine_StateSubscribe( &LED_FSM, &State_LEDBlink, NULL, State_LEDBlink_Callback, NULL, qFalse ); 

    qQueue_Setup( &LEDsigqueue, led_sig_stack, sizeof(qSM_Signal_t), qFLM_ArraySize(led_sig_stack) );
    qStateMachine_InstallSignalQueue( &LED_FSM, &LEDsigqueue );
/*

    qStateMachine_InstallTimeoutSpec( &LED_FSM, &tm_spectimeout );
    qStateMachine_Set_StateTimeouts( &State_LEDOn, LedOn_Timeouts, qFLM_ArraySize(LedOn_Timeouts) );
    qStateMachine_Set_StateTimeouts( &State_LEDBlink, LEDBlink_timeouts, qFLM_ArraySize(LEDBlink_timeouts) );

    qStateMachine_Set_StateTransitions( &State_LEDOff, LEDOff_transitions, qFLM_ArraySize(LEDOff_transitions) );
    qStateMachine_Set_StateTransitions( &State_LEDOn, LEDOn_transitions, qFLM_ArraySize(LEDOn_transitions) );
    qStateMachine_Set_StateTransitions( &State_LEDBlink, LEDBlink_transitions, qFLM_ArraySize(LEDBlink_transitions) );
  */
    qOS_Add_StateMachineTask(  &LED_Task, &LED_FSM, qMedium_Priority, 0.1f, qEnabled, NULL  );     
    qOS_Run();
}
