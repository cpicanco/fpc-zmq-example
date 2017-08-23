{
  Report 0MQ version
  @author cpicanco <cpicanco@ufpa.br>
}
program version;

uses zmq, zmq.version, zmq.helpers;

var
  context, responder : Pointer;
  rc: Integer;
begin
  ZMQVersion;

  context := zmq_ctx_new;
  responder := zmq_socket(context, ZMQ_REP);
  rc := zmq_bind(responder, 'tcp://*:5555');
  Assert(rc = 0);

  while True do
    WriteLn(ZMQRecvShortString(responder));
end.

