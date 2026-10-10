# 4.3BSD VAX780 instance manager -- 0BSD licensed, see LICENSE
#
#   just                 list instances
#   just new work        create instance "work"
#   just run work        boot it
#   just console work    boot with console on telnet 2323
#   just single work     boot to the Boot: prompt (then type: boot -s)
#   just kill work       stop a running instance
#   just snap work       snapshot its disk into instances/
#   just rm work         delete an instance
#   just pack            rebuild the package tarball
#   just list            same as bare `just`

pkg := justfile_directory()
default_src := env("HOME") + "/vax/4.3bsd"
home := env("HOME")
default: list

# show the installed 4.3BSD systems
list:
    @{{pkg}}/list.sh

# create an instance: `just new [name]`
new name="43bsd":
    {{pkg}}/create.sh {{name}}

# boot an instance: `just run [name]`
run name="43bsd":
    cd {{pkg}}/{{name}} && ./run.sh

# boot with the console on telnet localhost 2323
console name="43bsd":
    cd {{pkg}}/{{name}} && ./run.sh -t

# boot to the Boot: prompt, then type: boot -s
single name="43bsd":
    cd {{pkg}}/{{name}} && ./run.sh -s

# load the bootstrap without running the guest (drops to simh>)
simh name="43bsd":
    cd {{pkg}}/{{name}} && ./run.sh -n

# stop a running instance
kill name="43bsd":
    @pkill -f '{{pkg}}/{{name}}/vax780' && echo "sent SIGTERM to {{name}}" || echo "{{name}} was not running"

# snapshot an instance's disk: `just snap [name]`
snap name="43bsd":
    {{pkg}}/snapshot.sh {{name}}

# make a snapshot the image new instances are built from
promote name="43bsd":
    cp {{pkg}}/instances/{{name}}/rq.dsk.xz {{pkg}}/files/rq.dsk.xz
    @echo "new instances now use the {{name}} disk"

# delete an instance: `just rm [name]`
rm name="43bsd":
    {{pkg}}/destroy.sh {{name}}

# rebuild the package (images + tarball) from a source dir
pack src=default_src:
    {{pkg}}/pack.sh {{src}}

# build the package tarball from {{src}} (default ~/vax/4.3bsd)

# remove every instance (asks per instance)
clean:
    @for d in {{pkg}}/*/rq.dsk; do \
        [ -f "$$d" ] || continue; \
        {{pkg}}/destroy.sh "$$(basename $$(dirname $$d))" || exit 1; \
    done; true

# show paths and sizes
info:
    @echo "package:  {{pkg}}"
    @echo "tarball:  {{pkg}}/../43bsd-vax780.tar.xz"
    @ls -la {{pkg}}/../43bsd-vax780.tar.xz 2>/dev/null || echo "tarball not built yet -- just pack"