{
  fpc-zmq
  Copyright (C) 2017 Carlos Rafael Fernandes Picanço.

  The present file is distributed under the terms of the GNU Lesser General Public License (LGPL v3.0).

  You should have received a copy of the GNU Lesser General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit zmq.version;

interface

procedure ZMQVersion;

implementation

uses zmq;

procedure ZMQVersion;
var
  major, minor, patch : integer;
begin
  zmq_version(major, minor, patch);
  WriteLn(major,'.',minor,'.',patch);
end;

end.