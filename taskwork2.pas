{
  Task sink - design 2
  Adds pub-sub flow to send kill signal to workers
  @author cpicanco <cpicanco@ufpa.br>
}
program taskwork2;

{$mode objfpc}{$H+}

uses SysUtils, zmq, zmq.helpers;
const
  forever = False;

var
  context, receiver, sender, controller: Pointer;
  items : array [0..1] of zmq_pollitem_t;
  LString : string;
  optval : string = '';
begin



  #include "zhelpers.h"

  int main (void)
  {
      //  Socket to receive messages on
      void *context = zmq_ctx_new ();
      void *receiver = zmq_socket (context, ZMQ_PULL);
      zmq_bind (receiver, "tcp://*:5558");

      //  Socket for worker control
      void *controller = zmq_socket (context, ZMQ_PUB);
      zmq_bind (controller, "tcp://*:5559");

      //  Wait for start of batch
      char *string = s_recv (receiver);
      free (string);

      //  Start our clock now
      int64_t start_time = s_clock ();

      //  Process 100 confirmations
      int task_nbr;
      for (task_nbr = 0; task_nbr < 100; task_nbr++) {
          char *string = s_recv (receiver);
          free (string);
          if (task_nbr % 10 == 0)
              printf (":");
          else
              printf (".");
          fflush (stdout);
      }
      printf ("Total elapsed time: %d msec\n",
          (int) (s_clock () - start_time));

      //  Send kill signal to workers
      s_send (controller, "KILL");

      zmq_close (receiver);
      zmq_close (controller);
      zmq_ctx_destroy (context);
end.
