{
  Hello World server
  Binds REP socket to tcp://*:5555
  Expects "Hello" from client, replies with "World"
  @author cpicanco <cpicanco@ufpa.br>
}
program hwserver;

uses sysutils, zmq;

var
  context, responder: Pointer;
  rc : integer = 0;
  buffer : array [0..4] of Char;
  S : array [0..4] of Char = 'World';
begin
  //  Socket to talk to clients
  context := zmq_ctx_new;
  responder := zmq_socket(context, ZMQ_REP);
  rc := zmq_bind(responder, 'tcp://*:5555');
  Assert(rc = 0);
  WriteLn('hello world server initialized…');
  while True do
    begin
      zmq_recv(responder, @buffer, SizeOf(buffer), 0);
      Writeln('Received ', buffer);
      Sleep(1000); //  Do some 'work'
      WriteLn('Sending '+S+'…');
      zmq_send(responder, @S, SizeOf(S), 0);
    end;
end.