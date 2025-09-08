% �����N�p�����[�^
L1 = 60/10^3;  %% �P�ʂ̓��[�g��(m)
L2 = 20/10^3;
L3 = 20/10^3;
L4 = 95/10^3;
L5 = 8/10^3;
Lt = 35/10^3;
% �֐ߊp�x�i�Ƃ肠�����j
tht11 = 0;
tht12 = 0;
p1 = 0;
% DH�p�����[�^�̍쐬
dhparams =[0       pi    0     0;    % �x�[�X���W ��B
           L1+L3 3*pi/2  Lt  tht11;  % �W���C���g J11�i�\���֐߁j
           L1       0    0   tht12;  % �W���C���g J12�i�\���֐߁j
           L2      pi/2  L3    p1;  % �W���C���g J13�i�󓮊֐߁j
           L4      pi/2  L5  3*pi/2];    % �W���C���g C1�i�{�[���x�A�����O�j
% �c���[�I�u�W�F�N�g�̍쐬
robot = robotics.RigidBodyTree;
% �x�[�X���W�n
body1 = robotics.RigidBody('body1');
jnt1 = robotics.Joint('jnt1','revolute');
setFixedTransform(jnt1,dhparams(1,:),'dh');
body1.Joint = jnt1;
addBody(robot,body1,'base')
% �W���C���gJ11
body2 = robotics.RigidBody('body2');
jnt2 = robotics.Joint('jnt2','revolute');
setFixedTransform(jnt2,dhparams(2,:),'dh');
body2.Joint = jnt2;
addBody(robot,body2,'body1')
% �W���C���gJ12
body3 = robotics.RigidBody('body3');
jnt3 = robotics.Joint('jnt3','revolute');
setFixedTransform(jnt3,dhparams(3,:),'dh');
body3.Joint = jnt3;
addBody(robot,body3,'body2')
% �W���C���gJ13
body4 = robotics.RigidBody('body4');
jnt4 = robotics.Joint('jnt4','revolute');
setFixedTransform(jnt4,dhparams(4,:),'dh');
body4.Joint = jnt4;
addBody(robot,body4,'body3')
% �W���C���gC1
body5 = robotics.RigidBody('body5');
jnt5 = robotics.Joint('jnt5','revolute');
setFixedTransform(jnt5,dhparams(5,:),'dh');
body5.Joint = jnt5;
addBody(robot,body5,'body4')
% �\��
showdetails(robot)
show(robot);