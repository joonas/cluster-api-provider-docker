FROM golang:1.12.5
WORKDIR /cluster-api-upgrade-tool
ADD go.mod .
ADD go.sum .
RUN go mod download
RUN  curl -L https://dl.k8s.io/v1.14.3/kubernetes-client-linux-amd64.tar.gz | tar xvz
ADD cmd cmd
ADD actuators actuators
ADD kind kind
ADD execer execer
ADD third_party third_party

RUN go install -v ./cmd/capd-manager
RUN GO111MODULE="on" go get sigs.k8s.io/kind@v0.3.0
RUN curl https://get.docker.com | sh

FROM golang:1.12.5
COPY --from=0 /cluster-api-upgrade-tool/kubernetes/client/bin/kubectl /usr/local/bin
COPY --from=0 /go/bin/capd-manager /usr/local/bin
COPY --from=0 /go/bin/kind /usr/local/bin
COPY --from=0 /usr/bin/docker /usr/local/bin
ENTRYPOINT ["capd-manager"]
