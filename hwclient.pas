{
  Hello World client
  Connects REQ socket to tcp://localhost:5555
  Sends "Hello" to server, expects "World" back
  @author cpicanco <cpicanco@ufpa.br>
}
program hwclient;

uses zmq;

var
  context, requester : Pointer;
  i : integer;
  buffer : array [0..4] of Char;
  S : array [0..4] of Char = 'Hello';

begin
  WriteLn('Connecting to hello world server…');
  context := zmq_ctx_new;
  requester := zmq_socket(context, ZMQ_REQ);
  zmq_connect(requester, 'tcp://localhost:5555');
  for i := 0 to 9 do
    begin
      WriteLn('Sending '+S+'…');
      zmq_send(requester, @S, Sizeof(S), 0);
      zmq_recv(requester, @buffer, Sizeof(buffer), 0);
      WriteLn('Received ', buffer);
    end;
  zmq_close(requester);
  zmq_ctx_destroy(context);
end.