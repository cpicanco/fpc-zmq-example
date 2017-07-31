{
  Hello World server
  Binds REP socket to tcp://*:5555
  Expects "Hello" from client, replies with "World"
  @author cpicanco <cpicanco@ufpa.br>
}
program hwserver;

{$mode objfpc}{$H+}

// PACKSET 1

uses sysutils, zmq;

var
  context, responder: Pointer;
  rc : integer = 0;

  buffer : array [0..9] of Char;
  S : string = 'World';
begin
  //  Socket to talk to clients
  context := zmq_ctx_new;
  responder := zmq_socket(context, ZMQ_REP);
  rc := zmq_bind(responder, 'tcp://*:5555');
  Assert(rc = 0);

  while True do
    begin
      zmq_recv(responder, @buffer, 10, 0);
      Writeln('Received Hello');
      Sleep(1000); //  Do some 'work'
      zmq_send(responder, @S, Length(S), 0);
    end;
end.

