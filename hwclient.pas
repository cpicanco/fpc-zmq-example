{
  Hello World client
  Connects REQ socket to tcp://localhost:5555
  Sends "Hello" to server, expects "World" back
  @author cpicanco <cpicanco@ufpa.br>
}
program hwclient;

{$mode objfpc}{$H+} // string and PChar are converted to ansistring

uses zmq;

var
  context, requester : Pointer;
  request_nbr : integer;
  buffer : array [0..9] of Char;
  S : array [0..4] of Char = 'Hello';

begin
  WriteLn('Connecting to hello world server…');
  context := zmq_ctx_new;
  requester := zmq_socket(context, ZMQ_REQ);
  zmq_connect(requester, 'tcp://localhost:5555');
  WriteLn(Sizeof(S));
  for request_nbr := 1 to 10 do
    begin
      WriteLn('Sending '+S+' ', request_nbr, '…');
      zmq_send(requester, @S, Sizeof(S), 0);
      zmq_recv(requester, @buffer, Sizeof(buffer), 0);
      WriteLn('Received:', buffer, ' : ', request_nbr);
    end;
  zmq_close(requester);
  zmq_ctx_destroy(context);
end.

