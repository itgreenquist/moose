#ifndef GPMKERNELACTION
#define GPMKERNELACTION

#include "Action.h"

class GPMKernelAction: public Action
{
public:
  GPMKernelAction(const InputParameters & parameters);

  virtual void act();

};

template <>
InputParameters validParams<GPMKernelAction>();
#endif //GPMKERNELACTION
