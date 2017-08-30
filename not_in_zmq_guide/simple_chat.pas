{
  Public and private messages
  PUSH->POLL->PULL->PUB->SUB -> public
  REQ->POLL->REP -> private
}
program simple_chat;

{$mode objfpc}{$H+}{$COPERATORS ON}

uses
  {$IFDEF UNIX}cthreads, cmem{$ENDIF}, SysUtils,
  zmq, zmq.helpers;

const
  forever = False;

function subscriber_task(args: pointer): PtrInt;
var
  context, subscriber: Pointer;
  message : string;
  filter : string = 'message';
  rc: Integer;
begin
  context := zmq_ctx_new;
  subscriber := zmq_socket(context, ZMQ_SUB);
  zmq_connect(subscriber, 'tcp://localhost:1111');
  rc := zmq_setsockopt(subscriber, ZMQ_SUBSCRIBE, @filter[1], Length(filter));
  try
    repeat
      message := s_recv(subscriber);            // receive public message
      WriteLn('subscriber:'+message);
      message := '';
    until forever;
  finally
    zmq_close(subscriber);
    zmq_ctx_destroy(context);
    Result := PtrInt(0);
  end;
end;

function requester_trigger(args: pointer):PtrInt;
var
  context, requester: Pointer;
  reply : string;
begin
  context := zmq_ctx_new;
  requester := zmq_socket(context, ZMQ_REQ);
  zmq_connect(requester, 'tcp://localhost:4444');
  try
    repeat
      s_send(requester, 'request');             // request private message
      reply := s_recv(requester);               // receive private message
      WriteLn('requester: '+reply);
    until forever;
  finally
    zmq_close(requester);
    zmq_ctx_destroy(context);
    Result := PtrInt(0);
  end;
end;

function push_trigger(args: pointer): PtrInt;
var
  context, pusher: Pointer;
begin
  context := zmq_ctx_new;
  pusher := zmq_socket(context, ZMQ_PUSH);
  zmq_connect(pusher, 'tcp://localhost:7777');

  try
    repeat
      s_send(pusher, 'message');  // send public message
    until forever;
  finally
    zmq_close(pusher);
    zmq_ctx_destroy(context);
    Result := PtrInt(0);
  end;
end;

var
  context, replier, puller, publisher: Pointer;
  items: array [0..1] of zmq_pollitem_t;

  reply: string;
  i, rc: Integer;
begin
  context := zmq_ctx_new;
  publisher := zmq_socket(context, ZMQ_PUB);
  replier := zmq_socket(context, ZMQ_REP);
  puller := zmq_socket(context, ZMQ_PULL);

  zmq_bind(publisher, 'tcp://*:1111');
  zmq_bind(replier, 'tcp://*:4444');
  zmq_bind(puller, 'tcp://*:7777');

  for i := 0 to 4 do
    BeginThread(@subscriber_task);

  BeginThread(@push_trigger);
  BeginThread(@requester_trigger);

  // connecting takes time
  sleep(5000);

  with items[0] do
  begin
    socket := replier;
    fd := 0;
    events := ZMQ_POLLIN;
    revents := 0;
  end;
  with items[1] do
  begin
    socket := puller;
    fd := 0;
    events := ZMQ_POLLIN;
    revents := 0;
  end;

  i := 0;
  repeat
    sleep(10); // req-rep takes time
    if i >10 then break else i += 1;
    rc := zmq_poll(items[0], 2, -1);

    if rc = -1 then break;

    if (items[0].revents and ZMQ_POLLIN) > 0 then
    begin
      reply := s_recv(replier);
      s_send(replier, reply + ' received');   // private message received
      reply := '';
    end;

    if (items[1].revents and ZMQ_POLLIN) > 0 then
    begin
      reply := s_recv(puller);
      s_send(publisher, reply + ' published'); // public message published
      reply := '';
    end;
  until forever;

  zmq_close(publisher);
  zmq_close(puller);
  zmq_close(replier);
  zmq_ctx_destroy(context);
end.
